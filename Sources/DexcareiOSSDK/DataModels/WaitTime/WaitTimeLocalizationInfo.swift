//
// WaitTimeLocalizationInfo.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2022-09-08.
// Copyright © 2022 Providence. All rights reserved.
//

import Foundation

/// Information that allows to localize the estimated wait time
public struct WaitTimeLocalizationInfo: Decodable, Equatable {
    /// The modality of the visit. Can be used to keep separate localization options per modality
    public var modality: VirtualVisitModality
    /// The key of a string in which the estimatedWaitTimeMessage is based on.
    public var waitTimeMapKey: String
    /// An optional returned estimated minimum amount of seconds for a visit
    public var timeMinSeconds: Int?
    /// An optional returned estimated maximum amount of seconds for a visit
    public var timeMaxSeconds: Int?
    
    enum CodingKeys: String, CodingKey {
        case modality
        case waitTimeMapKey
        case timeMinSeconds
        case timeMaxSeconds
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        if let modalityString = try? container.decode(String.self, forKey: .modality) {
            modality = VirtualVisitModality(rawValue: modalityString)
        } else {
            modality = VirtualVisitModality(rawValue: "unknown")
        }
        
        self.waitTimeMapKey = try container.decode(String.self, forKey: .waitTimeMapKey)
        
        self.timeMinSeconds = try? container.decodeIfPresent(Int.self, forKey: .timeMinSeconds)
        self.timeMaxSeconds = try? container.decodeIfPresent(Int.self, forKey: .timeMaxSeconds)
    }
    
    // Initializer used only for stubbing tests
    internal init(
        modality: VirtualVisitModality,
        waitTimeMapKey: String,
        timeMinSeconds: Int?,
        timeMaxSeconds: Int?
    ) {
        self.modality = modality
        self.waitTimeMapKey = waitTimeMapKey
        self.timeMinSeconds = timeMinSeconds
        self.timeMaxSeconds = timeMaxSeconds
    }

}

extension WaitTimeLocalizationInfo {
    /// key to look up values in the localization strings file
    public var localizationKey: String {
        return "waitingRoom_waittime_\(modality.rawValue)_\(waitTimeMapKey)"
    }
}
