// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// Validates that a response meets certain criteria. If it does not, throws an error.
typealias ResponseValidator = (HTTPURLResponse, Data?) throws -> Void

let statusCodeIsIn200s: ResponseValidator = { response, data in
    guard 200 ..< 300 ~= response.statusCode else {
        throw NetworkError.non200StatusCode(statusCode: response.statusCode, data: data)
    }
}
