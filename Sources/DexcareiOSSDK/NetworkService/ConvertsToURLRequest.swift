// Copyright © 2019 Providence. All rights reserved.

import Foundation

/// Types adopting the `ConvertsToURLRequest` protocol can be used to construct URL requests.
protocol ConvertsToURLRequest {
    /// - returns: A URL request.
    func asURLRequest() -> URLRequest
}

extension URLRequest: ConvertsToURLRequest {
    func asURLRequest() -> URLRequest {
        return self
    }
}

extension URL: ConvertsToURLRequest {
    func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}
