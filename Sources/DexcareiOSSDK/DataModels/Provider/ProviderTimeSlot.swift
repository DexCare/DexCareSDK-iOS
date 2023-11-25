// Copyright © 2021 DexCare. All rights reserved.
import UIKit

/// Represents a grouping of time slots for a particular `Provider`
public struct ProviderTimeSlot: Equatable, Codable {
    /// The national identifier for this Provider
    public let providerNationalId: String
    /// Time slots starting after this Date/Time are included in the list of ScheduleDays
    /// - Important: This will return with GMT:0 for the timezone. You can effectively ignore time + timezone
    public let startDate: Date
    /// Time slots starting before this Date/Time are included in the list of ScheduleDays
    /// - Important: This will return with GMT:0 for the timezone. You can effectively ignore time + timezone
    public let endDate: Date
    /// The timezone of the Provider TimeSlot.
    public let timezoneString: String
    /// An array of ScheduleDay objects, each representing all time slots for a particular day
    public let scheduleDays: [ScheduleDay]
    /// A convenience `TimeZone` computed variable initialized with the `timezone` string property.
    public var timeZone: TimeZone? {
        return TimeZone(identifier: timezoneString)
    }
    
    enum CodingKeys: String, CodingKey {
        case providerNationalId
        case startDate
        case endDate
        case timezoneString = "timezone"
        case scheduleDays
    }
    
    // Initializer used only for stubbing tests
    internal init(
        providerNationalId: String,
        startDate: Date,
        endDate: Date,
        timezoneString: String,
        scheduleDays: [ScheduleDay]
    ) {
        self.providerNationalId = providerNationalId
        self.startDate = startDate
        self.endDate = endDate
        self.timezoneString = timezoneString
        self.scheduleDays = scheduleDays
    }
    
    /// An internal decoder to handle dates.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.providerNationalId = try values.decode(String.self, forKey: CodingKeys.providerNationalId)
        self.timezoneString = try values.decode(String.self, forKey: CodingKeys.timezoneString)
        self.scheduleDays = try values.decode([ScheduleDay].self, forKey: CodingKeys.scheduleDays)
        
        let startDateTimeString = try values.decode(String.self, forKey: CodingKeys.startDate)
        if let startDateTime = DateFormatter.yearMonthDay.date(from: startDateTimeString) {
            self.startDate = startDateTime
        } else {
            throw "Invalid startDate format"
        }
        
        let endDateTimeString = try values.decode(String.self, forKey: CodingKeys.endDate)
        if let endDateTime = DateFormatter.yearMonthDay.date(from: endDateTimeString) {
            self.endDate = endDateTime
        } else {
            throw "Invalid startDate format"
        }
    }
}
