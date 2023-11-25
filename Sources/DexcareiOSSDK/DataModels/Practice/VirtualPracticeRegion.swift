//
// PracticeRegion.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2020-12-21.
// Copyright © 2020 Providence. All rights reserved.
//

import Foundation
/// A structure representing a physical area serviced by a VirtualPractice
public struct VirtualPracticeRegion: Codable, Equatable {
    /// A UUID type of string for the `VirtualPracticeRegion`
    public var practiceRegionId: String
    /// A plain text string for the name of the `VirtualPracticeRegion`
    public var displayName: String
    /// A grandfathered unique string representing a region, used in `getCatchmentArea`. Typically a two-character string code
    public var regionCode: String
    /// A boolean indicating whether or not this PracticeRegion is active.
    /// If a practice region is not active, you should indicate so in your UI.
    /// - Warning: Any Virtual Visits booked with an inactive practice region will be rejected
    public var active: Bool
    /// A boolean indicating whether or not a practice region is busy and not available
    public var busy: Bool
     /// A custom plain text string to display when a practice region is busy
    public var busyMessage: String
     /// Price of the visit in dollars
    public var visitPrice: Decimal
    /// An array of `PracticeRegionAvailability`when a practice region is available.
    public var availability: [PracticeRegionAvailability]
    
    @available(*, unavailable, renamed: "pediatricsAgeRange", message: "Please use the correctly spelled pediatricsAgeRange")
    /// Pediatric age range
    public var pedatricsAgeRange: PediatricsAgeRange? {
        get { pediatricsAgeRange }
        set { pediatricsAgeRange = newValue }
    }
    
    /// Pediatric age range
    public var pediatricsAgeRange: PediatricsAgeRange?
    
    /// An array of departments available for this region
    public var departments: [PracticeRegionDepartment]
    
    enum CodingKeys: String, CodingKey {
        case practiceRegionId = "id"
        case displayName
        case regionCode
        case active
        case busy
        case busyMessage
        case visitPrice
        case availability
        case pediatricsAgeRange
        case departments
    }
    
    /// An internal decoder for VirtualPracticeRegion
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        practiceRegionId = try values.decode(String.self, forKey: .practiceRegionId)
        displayName = try values.decode(String.self, forKey: .displayName)
        regionCode = try values.decode(String.self, forKey: .regionCode)
        active = try values.decode(Bool.self, forKey: .active)
        busy = try values.decode(Bool.self, forKey: .busy)
        busyMessage = try values.decode(String.self, forKey: .busyMessage)
        
        let visitInCents = try values.decode(Int.self, forKey: .visitPrice)
        visitPrice = Decimal(visitInCents) / 100.0
        
        availability = try values.decode([PracticeRegionAvailability].self, forKey: .availability)
        pediatricsAgeRange = try? values.decode(PediatricsAgeRange.self, forKey: .pediatricsAgeRange)
        departments = try values.decode([PracticeRegionDepartment].self, forKey: .departments)
    }
}

// The pediatric age range used for providers that support pediatric visits
public struct PediatricsAgeRange: Codable, Equatable {
    // The minimum age (in months)
    public let min: Int?
    // The maximum age (in months)
    public let max: Int?
    
    public init(min: Int?, max: Int?) {
        self.min = min
        self.max = max
    }
}

/// Start and ending date times in UTC of a Practice Region
public struct PracticeRegionAvailability: Codable, Equatable {
    /// Start of operating hours
    /// - Important: Timezone will be in UTC (GMT:0)
    public let start: Date
    /// End of operating hours
    /// - Important: Timezone will be in UTC (GMT:0)
    public let end: Date
    
    enum CodingKeys: String, CodingKey {
        case start
        case end
    }
    
    /// An internal decoder for creating start and end times
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        let startText = try values.decode(String.self, forKey: .start)
        let endText = try values.decode(String.self, forKey: .end)
        
        guard
            let startDate = DateFormatter.iso8601Full.date(from: startText),
            let endDate = DateFormatter.iso8601Full.date(from: endText)
            else {
                throw "Region.Availability.OperatingHours decoder error for start:\(startText) and end:\(endText)"
        }
        
        start = startDate
        end = endDate
    }
}

/// Information about a department within a practice region
public struct PracticeRegionDepartment: Codable, Equatable {
    /// id of the department
    public let id: String
    
    /// epic id of the department
    public let epicDepartmentId: String
    
    /// ehr system name of the department
    public let ehrSystemName: String
    
    /// default name of the department
    public let defaultDepartmentName: String?
}
