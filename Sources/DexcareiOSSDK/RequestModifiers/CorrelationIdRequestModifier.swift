// Copyright © 2019 DexCare. All rights reserved.

import Foundation

class CorrelationIdRequestModifier: NetworkRequestModifier {

    /// Standard header field for a unique string ID
    /// https://provinnovate.atlassian.net/wiki/spaces/~soumya.sanyal/pages/133464108/Service+Request+Ergonomics
    static let correlationIdField = "Correlation-Id"
    private let idGenerator: () -> String

    /// Create a modifier with a correlation ID generator function.
    /// Default generator creates a UUID string.
    init(idGenerator: @escaping () -> String = { return UUID().uuidString }) {
        self.idGenerator = idGenerator
    }
    
    func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        let correlationId = idGenerator()
        mutableRequest.setValue(correlationId, forHTTPHeaderField: CorrelationIdRequestModifier.correlationIdField)
        return mutableRequest
    }
}
