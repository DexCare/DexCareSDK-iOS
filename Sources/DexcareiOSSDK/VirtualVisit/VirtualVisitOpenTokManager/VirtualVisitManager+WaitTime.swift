//
// VirtualVisitManager+WaitTime.swift
// DexcareSDK
//
// Created by Reuben Lee on 2020-01-23.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

internal enum Constants {
    static let waitTimeDefaultMessage = localizeString("waitingRoom_subtitle_providerWaitTime")
    static let estimateMessage = localizeString("waitingRoom_caption_estimatedTime")
    static let refreshInterval: TimeInterval = 60.0
    static let firstDelayInterval: TimeInterval = 5.0
}

extension VirtualVisitOpenTokManager {

    func loadWaitTime() {
        loadWaitTime(firstDelayInterval: Constants.firstDelayInterval)
    }
    
    func loadWaitTime(firstDelayInterval: TimeInterval) {
        waitingRoomView?.loadInitialWaitTime(waitTimeMessage: Constants.waitTimeDefaultMessage, estimateMessage: currentEstimateMessage)
        
        // sleep to let the server catch up before we try and load the first wait time
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(Int(firstDelayInterval))) { [weak self] in
            self?.updateWaitTime()
        }
    }
    
    private var currentEstimateMessage: String {
        return Constants.estimateMessage + " " + Date().asTimestampString()
    }
    
    func addWaitTimeWorkItem() {
        guard inWaitingRoom else { return }
        
        // Cancel any existing workItem if there is any
        if waitTimeWorkItem != nil {
            cancelWaitTimeWorkItem()
        }
        
        // Dispatch the work item based on wall time
        let workItem = DispatchWorkItem { [weak self] in
            self?.updateWaitTime()
        }
        waitTimeWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + Constants.refreshInterval, execute: workItem)
    }
    
    func updateWaitTime() {
        guard let virtualService else {
            waitingRoomView?.abortedWaitTime()
            return
        }
        
        Task {
            do {
                let waitTimeResponse = try await virtualService.getEstimatedWaitTime(visitId: visitId)
                let localizedWaitTimeMessage = getLocalizedWaitTimeMessage(waitTime: waitTimeResponse)
                let isEstimatedTimeBiggerThanMinWaitOffline = waitTimeResponse.estimatedWaitTimeSeconds >= minimumWaitTimeForWaitOffline
                let canWaitOffline = isEstimatedTimeBiggerThanMinWaitOffline && !forceWaitOfflineHidden
                DispatchQueue.main.async {
                    self.waitingRoomView?.updateWaitTime(
                        waitTimeMessage: localizedWaitTimeMessage ?? "",
                        estimateMessage: self.currentEstimateMessage,
                        canWaitOffline: canWaitOffline
                    )
                    self.logWaitOfflineServerLog(canWaitOffline: canWaitOffline,
                                                 estimatedWaitTime: waitTimeResponse.estimatedWaitTimeSeconds,
                                                 minimumWaitTimeForWaitOffline: self.minimumWaitTimeForWaitOffline,
                                                 forceWaitOfflineHidden: self.forceWaitOfflineHidden)
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.waitingRoomView?.abortedWaitTime()
                }
            }
            addWaitTimeWorkItem()
        }
    }
    
    func cancelWaitTimeWorkItem() {
        waitTimeWorkItem?.cancel()
        waitTimeWorkItem = nil
    }
    
    func getLocalizedWaitTimeMessage(waitTime: WaitTime) -> String? {
        // if I don't have any localizationInfo - return estimatedWaitTimeMessage from original response
        guard let localizationInfo = waitTime.waitTimeLocalizationInfo else {
            return waitTime.estimatedWaitTimeMessage
        }
        let localizationKey = localizationInfo.localizationKey
        
        // is there a better way to know when we have to replace strings?
        if let minSeconds = localizationInfo.timeMinSeconds,
            let maxSeconds = localizationInfo.timeMaxSeconds,
            let convertedTemplate = convertMinMaxTemplate(minSeconds: TimeInterval(minSeconds), maxSeconds: TimeInterval(maxSeconds), templateKey: localizationKey) {
            
            return convertedTemplate
        } else {
            let localizedString = localizeString(localizationKey)
            
            // could not find localized string
            if localizedString == localizationKey {
                return waitTime.estimatedWaitTimeMessage
            }
            return localizedString
        }
    }
    
    func convertMinMaxTemplate(minSeconds: TimeInterval, maxSeconds: TimeInterval, templateKey: String) -> String? {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .spellOut
        formatter.calendar = Calendar.current
        
        if let minSecondsString = formatter.string(from: minSeconds), let maxSecondsString = formatter.string(from: maxSeconds) {
            return String(format: localizeString(templateKey), minSecondsString, maxSecondsString)
        } else {
            return nil
        }
    }
    
    private func logWaitOfflineServerLog(canWaitOffline: Bool,
                                         estimatedWaitTime: Int,
                                         minimumWaitTimeForWaitOffline: Int,
                                         forceWaitOfflineHidden: Bool) {
        let visibleString = canWaitOffline ? "visible" : "NOT visible"
        serverLogger?.postMessage(message: "Wait Offline button is \(visibleString)",
                                  data: ["estimatedWaitTime": String(estimatedWaitTime),
                                         "minimumWaitTimeForWaitOffline": String(minimumWaitTimeForWaitOffline),
                                         "forceWaitOfflineHidden": String(forceWaitOfflineHidden)])
        
    }
}
