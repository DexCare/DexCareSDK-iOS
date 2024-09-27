//
// AggregatedSlot.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2022-10-14.
// Copyright © 2022 DexCare. All rights reserved.
//

import Foundation

@available(*, unavailable, renamed: "AggregatedSlot")
public struct AggregratedSlot {}

public struct AggregatedSlot: Codable, Equatable {
    /// The slotDateTime of the available time slot. In UTC
    public let slotDateTime: Date // 2022-10-18T16:20:00Z
    /// Department and Provider Information about the time slot
    public let providerOptions: [ProviderOptions]

    public let visitTypeName: String

    public init(slotDateTime: Date, providerOptions: [ProviderOptions], visitTypeName: String) {
        self.slotDateTime = slotDateTime
        self.providerOptions = providerOptions
        self.visitTypeName = visitTypeName
    }
}

public struct ProviderOptions: Codable, Equatable {
    /// Visit Type Identifier
    public let visitTypeId: String
    /// Department and Provider Information about the time slot
    public let provider: ProviderAvailability
    /// Duration (in minutes) of the time slot if available.
    public let duration: Int?
}
