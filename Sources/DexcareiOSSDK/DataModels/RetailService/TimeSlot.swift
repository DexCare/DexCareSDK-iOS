// Copyright © 2020 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
/// Represents an available time for an appointment.
public struct TimeSlot: Equatable, Codable {
    /// An unique identifier for this time slot
    public let slotId: String
    /// This time slot's Provider's national id
    public let providerNationalId: String
    // DC-4867 - for removal later.
    /// A unique identifier representing the Provider for this time slot
    public let providerId: String
    /// An identifier representing the Department for this time slot. Guaranteed to be unique in an ehr system, but not guaranteed to be unique across multiple ehr systems
    public let departmentId: String
    /// A string in the format {department's ehrSystemName}|{departmentId}
    public let departmentIdentifier: String
    /// What kind of appointment this time slot is for
    public let slotType: String
    /// A unique identifier representing the visit type
    public let visitTypeId: String
    /// How long the appointment is, in minutes
    public let durationInMin: Int
    /// The starting time and day of the appointment.
    /// - Important: Timezone will be local to the appointment.
    public let slotDateTime: Date

    enum CodingKeys: String, CodingKey {
        case slotId = "id"
        case providerNationalId
        case providerId
        case departmentId
        case departmentIdentifier
        case slotType
        case visitTypeId
        case durationInMin = "duration"
        case slotDateTime
    }

    public init(
        slotId: String,
        providerNationalId: String,
        providerId: String,
        departmentId: String,
        departmentIdentifier: String,
        slotType: String,
        visitTypeId: String,
        durationInMin: Int,
        slotDateTime: Date
    ) {
        self.slotId = slotId
        self.providerNationalId = providerNationalId
        self.providerId = providerId
        self.departmentId = departmentId
        self.departmentIdentifier = departmentIdentifier
        self.slotType = slotType
        self.visitTypeId = visitTypeId
        self.durationInMin = durationInMin
        self.slotDateTime = slotDateTime
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.slotId = try values.decode(String.self, forKey: CodingKeys.slotId)
        self.providerNationalId = try values.decode(String.self, forKey: CodingKeys.providerNationalId)
        self.providerId = try values.decode(String.self, forKey: CodingKeys.providerId)
        self.departmentId = try values.decode(String.self, forKey: CodingKeys.departmentId)
        self.departmentIdentifier = try values.decode(String.self, forKey: CodingKeys.departmentIdentifier)
        self.slotType = try values.decode(String.self, forKey: CodingKeys.slotType)
        self.visitTypeId = try values.decode(String.self, forKey: CodingKeys.visitTypeId)

        // We're reusing `TimeSlot` for Retail and Provider booking.
        let slotDateTimeString = try values.decode(String.self, forKey: CodingKeys.slotDateTime)
        if let slotDateTime = DateFormatter.iso8601FullDetailed.date(from: slotDateTimeString) {
            self.slotDateTime = slotDateTime
        } else {
            throw "Invalid slotDateTime format"
        }

        // So we're reusing `TimeSlot` for Retail and Provider booking.
        // Retail will return `duration` as a duration: "20"
        // Provider will return `duration` as duration: 20
        if let durationString = try? values.decode(String.self, forKey: CodingKeys.durationInMin) {
            if let duration = Int(durationString) {
                self.durationInMin = duration
            } else {
                throw "Invalid duration string"
            }
        } else if let duration = try? values.decode(Int.self, forKey: CodingKeys.durationInMin) {
            self.durationInMin = duration
        } else {
            throw "Invalid duration string or int"
        }
    }
}
