// Copyright © 2020 Providence. All rights reserved.

import Foundation

@available(*, unavailable, renamed: "RetailAppointmentTimeSlot")
public struct ClinicTimeSlot {}

/// Represents a grouping of time slots for a particular Retail clinic
public struct RetailAppointmentTimeSlot: Equatable, Codable {
    /// An identifier representing the Clinic for this time slot. Guaranteed to be unique in an ehr system, but not guaranteed to be unique across multiple ehr systems.
    public let departmentId: String
    /// Time slots starting after this Date/Time are included in the list of ScheduleDays
    public let startDate: Date
    /// Time slots starting before this Date/Time are included in the list of ScheduleDays
    public let endDate: Date
    /// The timezone of the Retail clinic
    public let timezone: String
    /// An array of ScheduleDay objects, each representing all time slots for a particular day
    public let scheduleDays: [ScheduleDay]
    
}
