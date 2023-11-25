//
// VirtualVisitOpenTok+Delegate.swift
// DexcareSDK
//
// Created by Reuben Lee on 2020-01-23.
// Copyright © 2020 Providence. All rights reserved.
//

import Foundation
import OpenTok

enum OpenTokError: Error {
    case jsonDataParsing
}

// MARK: - SessionType delegate callbacks
extension VirtualVisitOpenTokManager: SessionTypeDelegate {
    func sessionDidConnect(_ session: SessionType) {
        if visitState == .waitingRoom && waitingRoomView == nil && !inVisitOnResume {
            waitingRoomView = navigator.showWaitingRoom { [weak self] in
                guard let self else { return }
                self.virtualService?.onVisitSuccess(visitId: self.visitId)
            }
            waitingRoomView?.manager = self
            waitingRoomView?.tytoCareManager = self.tytoCareManager
            virtualService?.virtualEventDelegate?.onWaitingRoomLaunched()
            virtualService?.sendWaitingRoomEvents(visitId: self.visitId, permissions: nil)
        } else if session.sessionId == videoSessionId && inVisitOnResume {
            navigateToVisitView()
        }
        
        switch session.sessionId {
        case waitingRoomSessionId:
            sessionWaitingRoomFailedCount = 0
            logger?.log(LogMessages.visitWaitingRoomSessionJoin.sessionId(session.sessionId))
        case videoSessionId:
            sessionVideoFailedCount = 0
            logger?.log(LogMessages.visitVideoSessionJoin.sessionId(session.sessionId))
        default: break
        }
    }
    
    func sessionDidDisconnect(_ session: SessionType) {
        switch session.sessionId {
        case waitingRoomSessionId:
            virtualService?.virtualEventDelegate?.onWaitingRoomDisconnected()
        case videoSessionId:
            virtualService?.virtualEventDelegate?.onVirtualVisitDisconnected()
        default: break
        }
    }
    
    func session(_ session: SessionType, connectionCreated connection: OTConnection) {
        switch session.sessionId {
        case waitingRoomSessionId:
            logger?.log(LogMessages.visitWaitingRoomConnectionCreated.connectionId(connection.connectionId))
        case videoSessionId:
            logger?.log(LogMessages.visitVideoConnectionCreated.connectionId(connection.connectionId))
        default: break
        }
    }
    
    func session(_ session: SessionType, connectionDestroyed connection: OTConnection) {
        switch session.sessionId {
        case waitingRoomSessionId:
            logger?.log(LogMessages.visitWaitingRoomConnectionDestroyed.connectionId(connection.connectionId))
            
            virtualService?.virtualEventDelegate?.onWaitingRoomDisconnected()
            
        case videoSessionId:
            logger?.log(LogMessages.visitVideoConnectionDestroyed.connectionId(connection.connectionId))
            virtualService?.virtualEventDelegate?.onVirtualVisitDisconnected()
            
        default: break
        }
    }
    
    func session(_ session: SessionType, streamCreated stream: OTStream) {
        guard session.sessionId == videoSessionId else {
            logger?.log("Receiving stream from non video session: \(session.sessionId)", level: .warning)
            return
        }
        
        guard stream.connection.connectionData?.role == .provider else {
            logger?.log("Unable to create subscriber from streamId: \(stream.streamId), Receiving our own iOS patient stream", level: .warning)
            return
        }
        
        // in case there was already a subscriber
        defer {
            addNewSubscriber()
        }
        
        do {
            try cleanupSubscriber()
        } catch {
            self.logger?.log("Unable to cleanupSubscriber: \(String(describing: error))", level: .error)
        }
        
        func addNewSubscriber() {
            guard let subscriber = subscriberFactory.subscriber(stream: stream, delegate: self) else {
                self.logger?.log("Unable to create subscriber from streamId: \(stream.streamId), please notify OpenTok", level: .error)
                return
            }
            
            logger?.log("streamCreated: adding videoSubscriber", level: .verbose)
            
            videoSubscriber = subscriber
            
            do {
                try videoConferenceSession?.subscribe(subscriber: subscriber)
                
                logger?.log(LogMessages.visitVideoStreamCreated.streamId(stream.streamId))
            } catch {
                self.processError(error: error, isFatal: true, message: "Unable to subscribe to incoming video stream.")
            }
            
        }
    }
    
    func session(_ session: SessionType, streamDestroyed stream: OTStream) {
        guard
            videoSubscriber != nil,
            videoSubscriber?.streamId == stream.streamId
        else {
            self.logger?.log("stream destroyed but not the video subscriber: \(stream.streamId)", level: .warning)
            return
        }
        
        try? cleanupSubscriber()
        
        reconnecting()
        
        logger?.log(LogMessages.visitVideoStreamDestroyed.streamId(stream.streamId))
    }
    
    func session(_ session: SessionType, didFailWithError error: OTError) {
        // Retry at a small delay to make sure we don't use up all the retry attempt all at once
        // As the session connection can failed asynchronously, via calling bak at didFailWithError
        self.session(session, didFailWithError: error, retryDelay: .milliseconds(1000))
    }
    
    func session(_ session: SessionType, didFailWithError error: OTError, retryDelay: DispatchTimeInterval) {
        logger?.log(LogMessages.visitSessionDidFail.sessionId(session.sessionId, error: error))
        
        guard error.asOTSessionErrorCode == .OTConnectionDropped || error.asOTSessionErrorCode == .OTConnectionFailed else {
            processError(error: error, isFatal: true, message: "sessionDidFailWithError")
            return
        }
        
        // Make sure we only retry connecting a limited number of times
        if session.sessionId == waitingRoomSessionId && sessionWaitingRoomFailedCount < failedMaximumRetry {
            sessionWaitingRoomFailedCount += 1
            self.logger?.log("sessionWaitingRoomFailedCount: \(sessionWaitingRoomFailedCount)", level: .verbose)
            self.serverLogger?.postMessage(message: "Waiting Room session \(waitingRoomSessionId) failed - retrying #\(sessionWaitingRoomFailedCount)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                guard let self else { return }
                
                do {
                    try self.waitingRoomSession?.connect(token: self.waitingRoomToken)
                } catch {
                    self.processError(error: error, isFatal: true, message: "Unable to reconnect to waiting room session")
                }
            }
        } else if session.sessionId == videoSessionId && sessionVideoFailedCount < failedMaximumRetry {
            sessionVideoFailedCount += 1
            self.logger?.log("sessionVideoFailedCount: \(sessionVideoFailedCount)", level: .verbose)
            self.serverLogger?.postMessage(message: "Video Visit session \(videoSessionId) failed - retrying #\(sessionVideoFailedCount)")
            
            DispatchQueue.main.asyncAfter(deadline: .now() + retryDelay) { [weak self] in
                guard let self else { return }
                
                do {
                    try self.videoConferenceSession?.connect(token: self.videoToken)
                } catch {
                    self.processError(error: error, isFatal: true, message: "Unable to reconnect to visit session")
                }
            }
        } else {
            processError(error: error, isFatal: true, message: "sessionDidFailWithError")
        }
    }
    
    func sessionDidBeginReconnecting(_ session: SessionType) {
        // shows the Reconnecting UI
        reconnecting(timeout: false) // we will get the timeout error from didFailWithError instead
        logger?.log(LogMessages.visitSessionBeginReconnecting.sessionId(session.sessionId))
        
        switch session.sessionId {
        case waitingRoomSessionId:
            virtualService?.virtualEventDelegate?.onWaitingRoomReconnecting()
        case videoSessionId:
            virtualService?.virtualEventDelegate?.onVirtualVisitReconnecting()
        default: break
        }
    }
    
    func sessionDidReconnect(_ session: SessionType) {
        if videoConferenceSession?.sessionConnectionStatus == .connected &&
            waitingRoomSession?.sessionConnectionStatus == .connected {
            // Hides the Reconnecting UI
            reconnected()
            
            switch session.sessionId {
            case waitingRoomSessionId:
                virtualService?.virtualEventDelegate?.onWaitingRoomReconnected()
            case videoSessionId:
                virtualService?.virtualEventDelegate?.onVirtualVisitReconnected()
            default: break
            }
        }
        
        logger?.log(LogMessages.visitSessionDidReconnect.sessionId(session.sessionId))
    }
    
    func session(_ session: SessionType, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        guard
            let messageType = SignalMessageType(rawValue: type ?? "")
        else { return }
        
        let isWaitingRoomConnection = connection?.connectionId == waitingRoomSession?.connection?.connectionId
        let isVideoConnection = connection?.connectionId == videoConferenceSession?.connection?.connectionId
        let notMyOwnConnection = !isWaitingRoomConnection && !isVideoConnection
        
        switch messageType {
        case .participantLeft where notMyOwnConnection:
            endConference(reason: .completed)
        case .instantMessage:
            processInstantMessage(sessionId: session.sessionId, with: string)
        case .typingStateMessage:
            processTypingStateMessage(sessionId: session.sessionId, from: connection, with: string)
        case .error:
            processErrorMessage(with: string)
        case .statusChange:
            processStatusChange(with: string)
        default: break
        }
    }
    
    private func processInstantMessage(sessionId: String, with string: String?) {
        guard
            let jsonData = string?.data(using: .utf8)
        else { return }
        
        do {
            let instantMessage = try SignalInstantMessage(jsonData: jsonData)
            
            let chatMessage = instantMessage.asChatMessage
            switch sessionId {
            case videoSessionId:
                guard !videoChatMessages.contains(where: { $0.messageId == chatMessage.messageId }) else { return }
                videoChatMessages.append(chatMessage)
                videoChatMessages.sort { $0.sentDate < $1.sentDate }
                if visitState == .visit {
                    openChat()
                }
                logger?.log(.visitVideoInstantMessageReceived)
            case waitingRoomSessionId:
                guard !waitingRoomChatMessages.contains(where: { $0.messageId == chatMessage.messageId }) else { return }
                waitingRoomChatMessages.append(chatMessage)
                waitingRoomChatMessages.sort { $0.sentDate < $1.sentDate }
                if visitState == .waitingRoom && !inVisitOnResume {
                    openChat()
                }
                logger?.log(.visitWaitingRoomInstantMessageReceived)
            default: break
            }
        } catch {
            processError(error: error, isFatal: false, message: "Unable to parse incoming instant message")
        }
    }
    
    private func processTypingStateMessage(sessionId: String, from connection: OTConnection?, with string: String?) {
        guard
            waitingRoomSession?.connection?.connectionId != connection?.connectionId,
            videoConferenceSession?.connection?.connectionId != connection?.connectionId,
            let jsonData = string?.data(using: .utf8)
        else { return }
        
        do {
            let typingMessage = try RemoteTypingStateMessage(jsonData: jsonData)
            
            switch (visitState, sessionId, typingMessage.typingState) {
            case (.visit, videoSessionId, 1), (.waitingRoom, waitingRoomSessionId, 1):
                chatView?.remoteTypingStarted()
            case (.visit, videoSessionId, 0), (.waitingRoom, waitingRoomSessionId, 0):
                chatView?.remoteTypingStopped()
            default: break
            }
            
            switch sessionId {
            case waitingRoomSessionId:
                logger?.log(.visitWaitingRoomRemoteTypingState)
            case videoSessionId:
                logger?.log(.visitVideoRemoteTypingState)
            default: break
            }
        } catch {
            processError(error: error, isFatal: false, message: "Unable to parse incoming typing state")
        }
    }
    
    private func processErrorMessage(with string: String?) {
        guard let jsonData = string?.data(using: .utf8) else {
            processError(error: OpenTokError.jsonDataParsing, isFatal: false, message: "Unable to parse error signal message json data")
            return
        }
        
        do {
            let errorMessage = try ErrorMessage(jsonData: jsonData)
            
            if errorMessage.type == "joinedElsewhere" {
                endConference(reason: .joinedElsewhere)
            } else {
                logger?.log("unknown signal error message: \(errorMessage.type)")
            }
        } catch {
            processError(error: error, isFatal: false, message: "Unable to parse error signal message")
        }
    }
    
    private func processStatusChange(with string: String?) {
        guard let jsonData = string?.data(using: .utf8) else {
            processError(error: OpenTokError.jsonDataParsing, isFatal: false, message: "Unable to parse status change message json data")
            return
        }
        
        do {
            let statusMessage = try StatusChangedMessage(jsonData: jsonData)
            
            if statusMessage.status == "staffdeclined" { // staff declined visit from the provider portal
                virtualService?.virtualEventDelegate?.onVirtualVisitDeclinedByProvider()
                endConference(reason: .staffDeclined)
                logger?.log("staff declined virtual visit")
            } else {
                logger?.log("unknown status change message: \(statusMessage.status)")
            }
        } catch {
            processError(error: error, isFatal: false, message: "Unable to parse status change signal message")
        }
    }
}

// MARK: - OTPublisher delegate callbacks
extension VirtualVisitOpenTokManager: PublisherTypeDelegate {
    func publisher(_ publisher: PublisherType, streamCreated stream: OTStream) {
        isPublishing = true
        logger?.log("publisher stream created: \(stream.streamId)", level: .verbose)
    }
    
    func publisher(_ publisher: PublisherType, streamDestroyed stream: OTStream) {
        isPublishing = false
      
        try? cleanupPublisher()
    }
    
    func publisher(_ publisher: PublisherType, didFailWithError error: OTError) {
        processError(error: error, isFatal: false, message: "publisherDidFailWithError")
    }
}

// MARK: - OTSubscriber delegate callbacks
extension VirtualVisitOpenTokManager: SubscriberTypeDelegate {
    func subscriberDidConnect(toStream subscriberKit: SubscriberType) {
        reconnected()
        openVideoVisit()
        virtualService?.currentVirtualStartTime = Date()
        virtualService?.currentVirtualEndTime = nil
        logger?.log("subscriberDidConnect", level: .verbose)
    }
    
    func subscriberDidDisconnect(fromStream subscriber: SubscriberType) {
        reconnecting()
        logger?.log(.visitVideoSubscriberDidDisconnect)
    }
    
    func subscriberVideoDisableWarning(_ subscriber: SubscriberType) {
        reconnecting()
        logger?.log(.visitVideoSubscriberWarning)
    }
    
    func subscriberVideoDisableWarningLifted(_ subscriber: SubscriberType) {
        reconnected()
        logger?.log(.visitVideoSubscriberWarningLifted)
    }
    
    func subscriberDidReconnect(toStream subscriber: SubscriberType) {
        reconnected()
        logger?.log(.visitVideoSubscriberDidReconnect)
    }
    
    func subscriberVideoEnabled(_ subscriber: SubscriberType, reason: OTSubscriberVideoEventReason) {
        visitView?.enabledRemoteCamera = true
    }
    
    func subscriberVideoDisabled(_ subscriber: SubscriberType, reason: OTSubscriberVideoEventReason) {
        visitView?.enabledRemoteCamera = false
    }
    
    func subscriber(_ subscriber: SubscriberType, didFailWithError error: OTError) {
        processError(error: error, isFatal: false, message: "subscriberDidFailWithError")
        logger?.log(LogMessages.visitVideoDidFail.error(error))
    }
}

// MARK: SubscriberFactory

class SubscriberFactory {
    func subscriber(stream: OTStream, delegate: OTSubscriberKitDelegate?) -> SubscriberType? {
        return OTSubscriber(stream: stream, delegate: delegate)
    }
}

// MARK: Network Stats Callbacks
extension VirtualVisitOpenTokManager: NetworkStatsSubscriberDelegate, NetworkStatsPublisherDelegate {
    func subscriber(_ subscriber: SubscriberType, videoNetworkStatsUpdated stats: OTSubscriberKitVideoNetworkStats) {
        networkStats?.subscriberVideoStats.updateWithVideoStats(stats: stats)
    }
    func subscriber(_ subscriber: SubscriberType, audioNetworkStatsUpdated stats: OTSubscriberKitAudioNetworkStats) {
        networkStats?.subscriberAudioStats.updateWithAudioStats(stats: stats)
    }
    
    func publisher(_ publisher: PublisherType, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats]) {
        // check to see if stat count has changed and if so reset the array
        // NOTE: When we support multi-party we need to refactor/investigate how this change when people come and go on various connections
        if networkStats?.publisherVideoStats.count != stats.count {
            networkStats?.publisherVideoStats.removeAll()
            networkStats?.publisherVideoStats.append(contentsOf: repeatElement(PublisherNetworkStats(), count: stats.count))
        }
        
        for (index, element) in stats.enumerated() {
            networkStats?.publisherVideoStats[index].updateWithVideoStats(stats: element)
        }
    }
    func publisher(_ publisher: PublisherType, audioNetworkStatsUpdated stats: [OTPublisherKitAudioNetworkStats]) {
        // check to see if stat count has changed and if so reset the array
        // NOTE: When we support multi-party we need to refactor/investigate how this change when people come and go on various connections
        if networkStats?.publisherAudioStats.count != stats.count {
            networkStats?.publisherAudioStats.removeAll()
            networkStats?.publisherAudioStats.append(contentsOf: repeatElement(PublisherNetworkStats(), count: stats.count))
        }
        
        for (index, element) in stats.enumerated() {
            networkStats?.publisherAudioStats[index].updateWithAudioStats(stats: element)
        }
    }
}

// MARK: RTC Stats Callbacks
extension VirtualVisitOpenTokManager: RTCStatsSubscriberDelegate, RTCStatsPublisherDelegate {
    func subscriber(_ subscriber: SubscriberType, rtcStatsReport jsonArrayOfReports: String) {
        networkStats?.subscriberRTCStats = jsonArrayOfReports
    }
    
    func publisher(_ publisher: PublisherType, rtcStatsReport stats: [OTPublisherRtcStats]) {
        // NOTE: When we support multi-party we need to refactor/investigate how this change when people come and go on various connections
        if networkStats?.publisherRTCStats.count != stats.count {
            networkStats?.publisherRTCStats.removeAll()
            networkStats?.publisherRTCStats.append(contentsOf: repeatElement(PublisherRtcStats(), count: stats.count))
        }
        for (index, element) in stats.enumerated() {
            networkStats?.publisherRTCStats[index] = PublisherRtcStats(connectionId: element.connectionId, jsonArrayOfReports: element.jsonArrayOfReports)
        }
    }
}
