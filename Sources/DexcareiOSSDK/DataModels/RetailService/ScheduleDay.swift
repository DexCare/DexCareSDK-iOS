// Copyright © 2020 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
/// Represents a single day of available time slots.
public struct ScheduleDay: Equatable, Codable {
    /// The date the time slots represent
    /// - Important: This will return with the timezone of the Clinic or Provider. You can effectively ignore time + timezone as it should be used for grouping of `timeSlots`
    public let date: Date
    /// An array of time slots that are available
    public let timeSlots: [TimeSlot]

    enum CodingKeys: String, CodingKey {
        case date
        case timeSlots
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let dateString = try values.decode(String.self, forKey: CodingKeys.date)
        // We're reusing Schedule Day for Retail and Providers
        // Both endpoints come back with different date formats
        if let dateTime = DateFormatter.iso8601FullDetailed.date(from: dateString) {
            self.date = dateTime
        } else {
            throw "Invalid date format for ScheduleDay.date"
        }
        self.timeSlots = try values.decode([TimeSlot].self, forKey: CodingKeys.timeSlots)
    }

    // Initializer used only for stubbing tests
    init(
        date: Date,
        timeSlots: [TimeSlot]
    ) {
        self.date = date
        self.timeSlots = timeSlots
    }
}
