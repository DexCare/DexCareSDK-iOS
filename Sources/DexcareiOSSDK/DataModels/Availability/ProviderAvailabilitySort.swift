//
// ProviderAvailabilitySort.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2022-09-26.
// Copyright © 2022 DexCare. All rights reserved.
//

import Foundation

/// Provider availability sort return options
public enum ProviderAvailabilitySort: String, Codable {
    /// sort results by soonest available provider
    case nextAvailable
    /// sort results by most available provider
    case mostAvailable
}
