// Copyright © 2021 DexCare. All rights reserved.

import Foundation

public enum ScheduleProviderAppointmentFailedReason: Error, FailedReasonType {
    case patientNotLinked
    case patientNotFound
    case patientAccountLocked
    case conflictSlotUnavailable
    case conflictPatientDoubleBooked
    case unknownAppointmentConflict
    case internalServerError
    /// Validation of information failed. Please see message returned for more info
    case missingInformation(message: String)
    case failed(reason: FailedReason)
    /// Provider requires that the patient be on their panel before booking
    case patientNotOnPhysicalPanel

    static func from(error: Error) -> ScheduleProviderAppointmentFailedReason {
        if case let NetworkError.non200StatusCode(statusCode, data) = error {
            // Convert the response data to utf8 text
            let dataText = String(data: data ?? Data(), encoding: .utf8) ?? ""
            switch statusCode {
            case 400 where dataText.contains("Patient has no links"):
                return .patientNotLinked
            case 404 where dataText.contains("Patient not found"):
                return .patientNotFound
            case 409 where dataText.contains("SlotUnavailable"):
                return .conflictSlotUnavailable
            case 409 where dataText.contains("PatientDoubleBooked"):
                return .conflictPatientDoubleBooked
            case 409 where dataText.contains("UnknownAppointmentConflict"):
                return .unknownAppointmentConflict
            case 412:
                return .patientNotOnPhysicalPanel
            case 423:
                return .patientAccountLocked
            case 500:
                return .internalServerError
            default:
                return .failed(reason: FailedReason.from(error: error))
            }
        } else {
            return .failed(reason: FailedReason.from(error: error))
        }
    }

    public func failedReason() -> FailedReason? {
        if case let .failed(reason) = self {
            return reason
        } else {
            return nil
        }
    }
}
