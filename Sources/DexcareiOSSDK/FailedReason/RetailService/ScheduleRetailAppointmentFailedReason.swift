// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/*********
 Based on visit-service controller source code here:
 https://github.com/providenceinnovation/visit-service/blob/517f56d0aae74f7edf14db40a1d2007da1999a0a/app/src/controllers/retailvisitcontroller.ts#L323
 
 Server-side unit tests:
 https://github.com/providenceinnovation/visit-service/blob/517f56d0aae74f7edf14db40a1d2007da1999a0a/app/test/unit/controllers/retailvisitcontroller.test.ts#L1726
**********/

/// An `Error` enum returned for ScheduledVisits
public enum ScheduleRetailAppointmentFailedReason: Error, FailedReasonType {
    /// Patient has no demographics associated.
    case patientNotLinked
    /// Item is not found
    case patientNotFound
    /// Patient Account is locked. Please call customer service.
    case patientAccountLocked
    /// Time slot booked to has been taken. Please try another time slot
    case conflictSlotUnavailable
    /// Patient already has a time slot booked already
    case conflictPatientDoubleBooked
    /// An error happened when booking an appointment. Please try a new time slot
    case unknownAppointmentConflict
    /// An error happen on the server. If this continues, please notify us.
    case internalServerError
    /// Validation of information failed. Please see message returned for more info
    case missingInformation(message: String)
    /// A generic failure if we don't handle any specific schedule errors
    case failed(reason: FailedReason)
    
    static func from(error: Error) -> ScheduleRetailAppointmentFailedReason {
        if case NetworkError.non200StatusCode(let statusCode, let data) = error {
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
