//
// Practice.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2020-12-21.
// Copyright © 2020 Providence. All rights reserved.
//

import Foundation
/// A structure representing a Virtual Practice to which you can book a virtual visit
public struct VirtualPractice: Codable {
    /// A UUID for the Virtual Practice. This property will be needed to book Virtual Visits.
    public var practiceId: String
    /// A plain text string for the name of the Virtual Practice
    public var displayName: String
    /// A `PracticeCareMode` type of the practice. In the `VirtualPractice` type it will always be `virtual`
    public var careMode: PracticeCareMode
    /// A structure containing what types of payments are supported in the practice
    public var payment: PracticePaymentAvailability
    /// Does the virtual practice support Epic Booking
    public var epicBookingEnabled: Bool
    /// A list of `VirtualPracticeRegion` types where the practice is supported.
    public var practiceRegions: [VirtualPracticeRegion]
    
    enum CodingKeys: String, CodingKey {
        case practiceId = "id"
        case displayName
        case careMode
        case payment
        case epicBookingEnabled
        case practiceRegions
    }
}

/// An enum representing a type of care provided by a `VirtualPractice`.
public enum PracticeCareMode: String, Codable {
    /// a virtual visit type of care
    case virtual
    /// a retail visit type of care
    case retail
    /// Chat Care will be provided in a text chat.
    case chat
}

/// A structure that represents what type of payments are supported in a Practice
public struct PracticePaymentAvailability: Codable {
    /// Payment by insurance
    public let insurance: Bool
    /// Payment by credit card
    public let selfPay: Bool
    /// Payment by serviceKey / coupon code
    public let serviceKey: Bool
}
