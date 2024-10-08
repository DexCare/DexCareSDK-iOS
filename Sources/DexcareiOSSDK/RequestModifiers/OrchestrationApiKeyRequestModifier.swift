// Copyright © 2019 DexCare. All rights reserved.

import Foundation

class OrchestrationApiKeyRequestModifier: NetworkRequestModifier {
    static let apiHeader = "X-api-key"

    private(set) var apiKey: String
    init(apiKey: String) {
        self.apiKey = apiKey
    }

    func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        mutableRequest.setValue(apiKey, forHTTPHeaderField: OrchestrationApiKeyRequestModifier.apiHeader)
        return mutableRequest
    }
}
