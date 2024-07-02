// Copyright © 2020 DexCare. All rights reserved.

import Foundation

@available(*, unavailable, renamed: "RetailDepartment")
public struct Clinic {}

/// A struct to represent a RetailDepartment.. ex clinic
public struct RetailDepartment: Equatable, Codable {
    /// The brand that the retail department belongs to
    public let brandName: String
    
    /// A name for the retail department
    public let displayName: String
    /// An Address object of the retail department
    public let address: Address
    
    /// The retail department phone number
    public let phone: String
    
    /// An image url that will return a jpg of the location
    public let smallImageUrl: URL
    
    /// longitude of the physical location of the retail department
    public let longitude: Double
    /// latitude of the physical location of the retail department
    public let latitude: Double
    
    /// The EHRSystemName of where the retail department belongs
    public let ehrSystemName: String
    
    /// The unique name for a retail department . Previously `urlName`
    public let departmentName: String
    
    /// Which timezone string the retail department is in.
    public let timezone: String
    /// The internal departmentId of the retail department
    public let departmentId: String
    /// What type of retail department . eg. Retail, Virtual.
    public let clinicType: String
    /// Whether or not the retail department is Active.
    public let isActive: Bool
    /// The internal instance Id
    public let instanceId: String
    /// A list of visit types that are allowed on this clinic. This will need to be passed up when getTimeSlots is called
    public let allowedVisitTypes: [AllowedVisitType]
    /// A list of days with times that the retail department is open
    public let openDays: [OpenDay]
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case brandName = "brandName"
        case displayName = "displayName"
        case address = "address"
        case phone = "phone"
        case smallImageUrl = "smallImageUrl"
        case longitude = "longitude"
        case latitude = "latitude"
        case ehrSystemName = "ehrSystemName"
        case departmentName = "urlName"
        case timezone = "timezone"
        case departmentId = "departmentId"
        case clinicType = "clinicType"
        case isActive = "isActive"
        case instanceId = "instanceId"
        case allowedVisitTypes = "allowedVisitTypes"
        case openDays = "openDays"
    }
}

/// A `RawRepresentable` structure representing a visit type that is supported by Epic.
///
/// - Note: A `VisitType` in this context is simply a `String`. You can exchange a `VisitType` with a string without issue.
/**
 /// When new a VisitType is created, you can extend the VisitType struct to represent the new type.
 ```
 extension VisitType {
    static let vaccinePfizerVisitType = VisitType(rawValue: "Vaccine-Pfizer")
 }
 ```
 This will allow you to create a new VisitType without having to have a new SDK version.
 */
public struct VisitTypeShortName: RawRepresentable, Codable, Equatable {
    public typealias RawValue = String
    public var rawValue: String
    
    // DexCare Visit Types
    /// Visit Type of **Illness** shortName
    public static let illness = VisitTypeShortName(rawValue: "Illness")
    /// Visit Type of **Wellness** shortName
    public static let wellness = VisitTypeShortName(rawValue: "Wellness")
    /// Visit Type of **Virtual** shortName
    public static let virtual = VisitTypeShortName(rawValue: "Virtual")
    
    // Provider Scheduling Visit Types
    /// Visit Type of **FollowUp** shortName
    public static let followUp = VisitTypeShortName(rawValue: "FollowUp")
    /// Visit Type of **NewPatient** shortName
    public static let newPatient = VisitTypeShortName(rawValue: "NewPatient")
    /// Visit Type of **WellChild** shortName
    public static let wellChild = VisitTypeShortName(rawValue: "WellChild")
    /// Visit Type of **AdultPhysical** shortName
    public static let adultPhysical = VisitTypeShortName(rawValue: "AdultPhysical")
    /// Visit Type of **ChildPhysical** shortName
    public static let childPhysical = VisitTypeShortName(rawValue: "ChildPhysical")
    /// Visit Type of **NewSymptoms** shortName
    public static let newSymptoms = VisitTypeShortName(rawValue: "NewSymptoms")
    
    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}

/// A structure containing information about the visit type that is allowed on a clinic
public struct AllowedVisitType: Equatable, Codable {
    /// A string representing the internal id of the VisitType. Used in some SDK calls.
    public let visitTypeId: String
    
    /// A string describing the Allowed Visit Type
    public let name: String
    
    /// A `VisitType` describing the Allowed Visit Type in short form. Used in some SDK calls. `VisitType` is simply a string representation for easiness
    public let shortName: VisitTypeShortName
}

/// A structure containing a day string (Sunday, Monday, etc) and the start/end times of the day
public struct OpenDay: Equatable, Codable {
    /// The day of the week in full string (Sunday, Monday, Tuesday)
    public let day: String
    /// An `OpenHours` property indicating the start and end time of a clinic
    public let openHours: OpenHours
}

/// A structure containing information about the opening and closing times of a clinic.
public struct OpenHours: Equatable, Codable {
    /// The time the clinic opens, in the format HH:mm:ss
    public let startTimeString: String
    /// The time the clinic closes, in the format HH:mm:ss
    public let endTimeString: String
    
    // Codable
    enum CodingKeys: String, CodingKey {
        case startTimeString = "startTime"
        case endTimeString = "endTime"
    }
}
