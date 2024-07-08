// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// An `Error` enum returned for VerifyCouponCode
public enum CouponCodeFailedReason: Error, FailedReasonType {
    /// 401 status code
    case unauthorized

    /// 404 status code
    case notFound

    /// 429 status code
    case tooManyRequests

    /// 500 status code
    case internalServerError

    /// Coupon code is known to be inactive
    case inactive
    
    /// Some information is missing from the request. Check the message 
    case missingInformation(message: String)

    /// Fallback failure case not matching any other expected failure
    case failed(reason: FailedReason)
    
    static func from(error: Error) -> CouponCodeFailedReason {
        switch error {
        case let reason as CouponCodeFailedReason: return reason
        case NetworkError.non200StatusCode(let statusCode, _):
            switch statusCode {
            case 401:
                return .unauthorized
            case 404:
                return .notFound
            case 429:
                return .tooManyRequests
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
}
