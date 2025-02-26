//
// ScheduledVisit.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2020-06-04.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// Contains details about an upcoming scheduled visit
public struct ScheduledVisit: Equatable, Codable {
    /// A unique identifier representing this visit
    public let id: String
    /// The type of visit: Retail, Virtual or At Home
    public let type: ScheduledVisitType
    /// An enum representing the current status of the visit
    public let status: ScheduledVisitStatus
    /// The patient's address
    public let address: Address
    /// An `AppointmentDetails` object containing additional details about the appointment
    public let appointmentDetails: AppointmentDetails
    /// The ID of the department where the visit is scheduled
    public let departmentId: String
    /// The ehrSystem in which the visit is scheduled
    public let ehrSystemName: String
    /// A flag to indicate if a new patient record was created or not for a visit
    public let isNewPatient: Bool
    /// A flag to indicate whether a PRR or a provider indicates that the visit is ready to happen
    public let isReadyForVisit: Bool
    /// The patient's contact email
    public let patientEmail: String?
    /// The unique identifier representing a DexCare Patient
    public let patientGuid: String
    /// The patient's contact phone number
    public let patientPhone: String?
    /// A `Timestamps` object containing specific dateTimes indicating when the visit was updated
    public let timestamps: Timestamps

    /// A `RetailDepartment` containing information about the department where the visit was scheduled. Present only for Retail visit type, nil otherwise.
    public var retailDepartment: RetailDepartment?

    func departmentURLKey() -> String {
        return ehrSystemName + "|" + departmentId
    }

    // Codable
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case type = "type"
        case status = "status"
        case address = "address"
        case appointmentDetails = "appointment"
        case departmentId = "departmentId"
        case ehrSystemName = "ehrSystemName"
        case isNewPatient = "isNewPatient"
        case isReadyForVisit = "isReadyForVisit"
        case patientEmail = "patientEmail"
        case patientGuid = "patientGuid"
        case patientPhone = "patientPhone"
        case timestamps = "timestamps"
    }

    /// Additional details about the appointment
    public struct AppointmentDetails: Equatable, Codable {
        /// A unique id for the appointment
        public let appointmentId: String
        /// Base 64 encoded string representing the slot
        public let slotId: String
        /// The start time of the appointment
        /// - Important: date will be in the timezone of the appointment
        public let startDateTime: Date
        /// The end time of the appointment
        /// - Important: date will be in the timezone of the appointment
        public let endDateTime: Date
        /// The timezone string the appointment is scheduled in
        public let timezone: String

        // Codable
        enum CodingKeys: String, CodingKey {
            case appointmentId = "appointmentId"
            case startDateTime = "start"
            case endDateTime = "end"
            case slotId = "slotId"
            case timezone = "timezone"
        }

        // Initializer used only for stubbing tests
        init(
            appointmentId: String,
            slotId: String,
            startDateTime: Date,
            endDateTime: Date,
            timezone: String
        ) {
            self.appointmentId = appointmentId
            self.slotId = slotId
            self.startDateTime = startDateTime
            self.endDateTime = endDateTime
            self.timezone = timezone
        }
    }

    /// An struct representing various times at which a `ScheduledVisit` was updated
    public struct Timestamps: Equatable, Codable {
        /// The day and time at which the visit was cancelled. nil if not applicable
        public let cancelled: Date?
        /// The day and time at which the visit was completed. nil if not applicable
        public let done: Date?
        /// The day and time at which the visit was requested. nil if not applicable
        public let requested: Date?
        /// The day and time at which the visit was staff declined. nil if not applicable
        public let staffDeclined: Date?

        // Codable
        enum CodingKeys: String, CodingKey {
            case cancelled = "cancelled"
            case done = "done"
            case requested = "requested"
            case staffDeclined = "staffDeclined"
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            if let requestedText = try? values.decodeIfPresent(String.self, forKey: .requested) {
                requested = DateFormatter.iso8601Full.date(from: requestedText)
            } else {
                requested = nil
            }

            if let cancelledText = try? values.decodeIfPresent(String.self, forKey: .cancelled) {
                cancelled = DateFormatter.iso8601Full.date(from: cancelledText)
            } else {
                cancelled = nil
            }

            if let doneText = try? values.decodeIfPresent(String.self, forKey: .done) {
                done = DateFormatter.iso8601Full.date(from: doneText)
            } else {
                done = nil
            }

            if let staffDeclinedText = try? values.decodeIfPresent(String.self, forKey: .staffDeclined) {
                staffDeclined = DateFormatter.iso8601Full.date(from: staffDeclinedText)
            } else {
                staffDeclined = nil
            }
        }

        // Initializer used only for stubbing tests
        init(
            cancelled: Date?,
            done: Date?,
            requested: Date?,
            staffDeclined: Date?
        ) {
            self.cancelled = cancelled
            self.done = done
            self.requested = requested
            self.staffDeclined = staffDeclined
        }
    }
}

/// An enum representing the type of a ScheduledVisit: Retail, Virtual, or At Home.
///
/// Any new ScheduledVisitTypes that are not supported will automatically return `.unknown`
public enum ScheduledVisitType: String, Codable, Equatable {
    case home = "home"
    case retail = "retail"
    case virtual = "virtual"
    case unknown = "unknown"

    public init(from decoder: Decoder) throws {
        self = try ScheduledVisitType(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
    }
}

/// An enum representing the status of a ScheduledVisit
///
/// Any new ScheduledVisitStatus that are not supported will automatically return `.unknown`
public enum ScheduledVisitStatus: String, Codable, Equatable {
    case requested = "requested"
    @available(*, unavailable, renamed: "waitingRoom")
    case waitingroom = "old waitingroom"
    case waitingRoom = "waitingroom"
    case inVisit = "invisit"
    case staffDeclined = "staffdeclined"
    case verification = "verification"
    case cancelled = "cancelled"
    case done = "done"
    case unknown = "unknown"

    public init(from decoder: Decoder) throws {
        self = try ScheduledVisitStatus(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
    }
}
