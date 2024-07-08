// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// Represents a type that adds persistent details to a URL Request. (Ex: adding headers with authentication)
protocol NetworkRequestModifier {
    /// Add authentication details to a URL Request (for example, by adding authentication headers)
    ///
    /// - returns: The modified URL Request
    func mutate(_ request: URLRequest) -> URLRequest
}

extension NetworkRequestModifier {
    func mutate(_ requestModifiable: ConvertsToURLRequest) -> URLRequest {
        let urlRequest = requestModifiable.asURLRequest()
        return mutate(urlRequest)
    }
}
