// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// A enum of possible errors that may come from the SDK
/// More specific errors may be returned in `VirtualVisitFailedReason`,
public enum FailedReason: Error {
    /// Returned when a piece of information is missing. See the `message` for more information
    case missingInformation(message: String)
    /// SDK has called the server, but something is still missing.
    case badRequest
    /// SDK has called the server, but something is still missing. See `info` for more information
    case badDexcareRequest(info: DexcareAPIError)
    /// The token that the SDK has is invalid. A new token is needed.
    case unauthorized
    /// The item doesn't seem to exist in our system
    case notFound
    /// If we don't know what the error was, it will pass through here. Check the `error` property
    case unknown(error: Error)
    /// All data is present but some property didn't pass a validation. Please check `message` property that is returned.
    /// ex: **startDate must be at least today**
    case invalidInput(message: String)
    
    static func from(error: Error) -> FailedReason {       
        if case let NetworkError.non200StatusCode(statusCode, _) = error {
            switch statusCode {
            case 400:
                return .badRequest
            case 401:
                return .unauthorized
            case 404:
                return .notFound
            case 432:
                return .badRequest
            default:
                return .unknown(error: error)
            }
        } else {
            return .unknown(error: error)
        }
    }
    
}

extension FailedReason: LocalizedError {
    /// A more descriptive reason for the error.
    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Invalid token. Please log in again."
        case .notFound:
            return "Information does not exist"
        case .unknown(let reason):
            return "An error occurred: \(reason.localizedDescription)"
        case .missingInformation(let message):
            return "Information that is required is missing: \(message)"
        case .badRequest:
            return "Server returned as a bad request. Please check your inputs."
        case .badDexcareRequest(let info):
            return "Server returned as a bad request - \(info.message). Error: \(info.errorCode)"
        case .invalidInput(let message):
            return "Input is invalid: \(message)"
        }
    }
}

public protocol FailedReasonType {
    func failedReason() -> FailedReason?
}
