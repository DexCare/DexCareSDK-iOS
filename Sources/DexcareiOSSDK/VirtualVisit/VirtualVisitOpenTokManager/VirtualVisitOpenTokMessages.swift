//
// VirtualVisitOpenTokMessages.swift
// DexcareSDK
//
// Created by Reuben Lee on 2020-01-21.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

enum SignalMessageType: String {
    case instantMessage,
         typingStateMessage,
         participantLeft,
         error,
         statusChange,
         endCallAndTransfer,
         patientEnterWaitOfflineSuccess,
         patientEnterWaitOfflineError,
         /// Indicates that the virtual visit was converted to another type. ie. a phone visit.
         modalityConversion
}

struct SignalInstantMessage: Codable {
    var fromParticipant: String
    var senderId: String?
    var creationTime: Date
    var uniqueId: String
    var message: String
    var isStaff: Bool?

    enum CodingKeys: String, CodingKey {
        case fromParticipant
        case senderId
        case creationTime
        case uniqueId
        case message
        case isStaff
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        fromParticipant = try container.decode(String.self, forKey: .fromParticipant)
        senderId = try? container.decode(String.self, forKey: .senderId)
        uniqueId = try container.decode(String.self, forKey: .uniqueId)
        message = try container.decode(String.self, forKey: .message)
        isStaff = try container.decodeIfPresent(Bool.self, forKey: .isStaff)

        let creationTimeText = try container.decode(String.self, forKey: .creationTime)

        // Web uses epoch milliseconds so we need to convert it
        creationTime = Date(timeIntervalSince1970: (Double(creationTimeText) ?? 0) / 1000)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(fromParticipant, forKey: .fromParticipant)
        try container.encode(uniqueId, forKey: .uniqueId)
        try container.encode(message, forKey: .message)

        try container.encodeIfPresent(senderId, forKey: .senderId)
        try container.encodeIfPresent(isStaff, forKey: .isStaff)

        // Web uses epoch milliseconds so we need to convert it
        try container.encode("\(Int(creationTime.timeIntervalSince1970 * 1000))", forKey: .creationTime)
    }

    init(
        fromParticipant: String,
        senderId: String?,
        creationTime: Date,
        uniqueId: String,
        message: String,
        isStaff: Bool?
    ) {
        self.fromParticipant = fromParticipant
        self.senderId = senderId
        self.creationTime = creationTime
        self.uniqueId = uniqueId
        self.message = message
        self.isStaff = isStaff
    }
}

struct RemoteTypingStateMessage: Codable {
    let displayName: String
    let typingState: Int
}

struct ErrorMessage: Codable {
    let type: String
}

struct ConnectionData: Codable {
    let visitId: String
    let role: ConnectionRole
}

enum ConnectionRole: String, Codable {
    case patient
    case provider
    case participant
}

struct StatusChangedMessage: Codable {
    let status: String
}
