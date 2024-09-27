// Copyright © 2019 DexCare. All rights reserved.
import UIKit

struct DomainNetworkRequestModifier: NetworkRequestModifier {
    private let headerKey = "domain"
    private(set) var domain: String

    init(domain: String) {
        self.domain = domain
    }

    func mutate(_ request: URLRequest) -> URLRequest {
        guard domain.isNotEmpty else {
            fatalError("DomainNetworkRequestModifier.domain has not been set. Unable to make network call.")
        }

        var result = request
        result.setValue(domain, forHTTPHeaderField: headerKey)
        return result
    }
}
