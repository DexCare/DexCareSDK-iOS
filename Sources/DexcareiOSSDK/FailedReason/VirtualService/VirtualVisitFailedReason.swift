// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// An `Error` enum returned when ScheduleVirtualVisit
public enum VirtualVisitFailedReason: Error, FailedReasonType {
    /// Missing some data in a request
    case incompleteRequestData
    /// Missing data in a request. See the message that is being returned for more information.
    case missingInformation(message: String)
    /// Email is not valid. To check, use `EmailValidator.isValid(email)`
    case invalidEmail
    /// Visit is expired. Please create a new visit.
    case expired
    /// Region is currently busy. Use `PracticeService.getVirtualPracticeRegionAvailability` to get more information
    case regionBusy
    /// When setting up a Virtual Visit. The user has denied a Camera or Microphone permission.
    case permissionDenied(type: PermissionType)
    /// A generic failure when not handled specifically in VirtualVisitFailedReason
    case failed(reason: FailedReason)
    /// The virtual visit id does not exist.
    case virtualVisitNotFound
    /// The visit type is not supported
    case visitTypeNotSupported
    /// The server returned an error. See message for details
    case invalidRequest(message: String)
    
    public struct PermissionType: OptionSet {
        public let rawValue: UInt8
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
        
        public static let camera = PermissionType(rawValue: 1 << 0)
        public static let microphone = PermissionType(rawValue: 1 << 1)
        public static let notifications = PermissionType(rawValue: 1 << 2)
    }
    
    static func from(error: Error) -> VirtualVisitFailedReason {
        switch error {
        case let reason as VirtualVisitFailedReason: return reason
        case NetworkError.non200StatusCode(let statusCode, let data):
            // Convert the response data to utf8 text.
            let dataText = String(data: data ?? Data(), encoding: .utf8) ?? ""
            // FailureResponse is a newer way of return error codes.
            let errorResponse: FailureResponse? = try? FailureResponse(jsonData: data ?? Data())
            
            switch statusCode {
            case 400 where dataText.contains("REGION_BUSY"):
                return .regionBusy
            case 400 where errorResponse?.code == "VISIT_CREATE_ERROR":
                return .invalidRequest(message: errorResponse?.error ?? "Invalid data sent")
            case 404:
                return .virtualVisitNotFound
            default:
                return .failed(reason: FailedReason.from(error: error))
            }
        default:
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

internal struct FailureResponse: Codable {
    let code: String
    let error: String?
}
