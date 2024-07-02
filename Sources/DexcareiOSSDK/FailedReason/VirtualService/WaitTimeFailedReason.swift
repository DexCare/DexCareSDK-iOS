import Foundation

/// An `Error` enum returned for Estimated Wait Times
public enum WaitTimeFailedReason: Error, FailedReasonType, Equatable {
    /// There are no Providers that are on call in the PracticeRegion.
    case noOnCallProviders

    /// The Practice Region is off hours.
    case offHours
    
    /// The Practice Region is experiencing high demand (busy).
    case regionBusy
    
    /// The `PracticeRegionId` passed in does not exist on our system
    case regionNotFound

    /// The visit with the given visitId was not found.
    case visitNotFound
    
    /// Something went wrong internally. Please send us the correlation id.
    case internalServerError
    
    /// Some information is missing from the request. Check the message
    case missingInformation(message: String)
    
    /// Fallback failure case not matching any other expected failure
    case failed(reason: FailedReason)
    
    static func from(error: Error) -> WaitTimeFailedReason {
        switch error {
        case let reason as WaitTimeFailedReason: return reason
        case NetworkError.non200StatusCode(let statusCode, let data):
            // Convert the response data to utf8 text
            let dataText = String(data: data ?? Data(), encoding: .utf8) ?? ""
            switch statusCode {
            case 400 where dataText.contains("OFF_HOURS"):
                return .offHours
            case 400 where dataText.contains("REGION_BUSY"):
                return .regionBusy
            case 400 where dataText.contains("NO_ONCALL_PROVIDERS"):
                return .noOnCallProviders
            case 400 where dataText.contains("NO_REGIONS_FOUND"):
                return .regionNotFound
            case 404:
                return .visitNotFound
            case 500:
                return .internalServerError
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
    
    public static func == (lhs: WaitTimeFailedReason, rhs: WaitTimeFailedReason) -> Bool {
        String(reflecting: lhs) == String(reflecting: rhs)
    }
}
