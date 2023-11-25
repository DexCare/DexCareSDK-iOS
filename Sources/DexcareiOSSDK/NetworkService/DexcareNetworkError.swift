// Copyright © 2019 Providence. All rights reserved.

import Foundation

extension Error {
    func isNetworkError(withStatusCode statusCode: Int) -> Bool {
        guard
            let networkError = self as? NetworkError,
            case let .non200StatusCode(errorCode, _) = networkError,
            errorCode == statusCode
        else {
            return false
        }
        
        return true
    }
}
