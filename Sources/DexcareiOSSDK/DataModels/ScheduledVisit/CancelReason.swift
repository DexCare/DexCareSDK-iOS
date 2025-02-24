//
// CancelReason.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2020-06-18.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// Contains details about a reason for a person to cancel an appointment. These are based on brand
public struct CancelReason: Equatable, Hashable {
    /// A string that should be displayed to the user
    public var displayText: String
    /// The internal code that is passed through for the reason for cancelling
    public var code: String

    public init(
        displayText: String,
        code: String
    ) {
        self.displayText = displayText
        self.code = code
    }
}

extension CancelReason: Codable {
    private enum CodingKeys: String, CodingKey {
        case displayText = "clientText"
        case code = "stringCode"
    }
}
