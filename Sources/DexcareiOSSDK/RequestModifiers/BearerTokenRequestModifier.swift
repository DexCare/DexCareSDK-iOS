// Copyright © 2018 Providence. All rights reserved.

import Foundation

class BearerTokenRequestModifier: NetworkRequestModifier {

    private var authenticationToken: String
    init(authenticationToken: String) {
        self.authenticationToken = authenticationToken
    }

    func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        let bearerTokenHeader = "Bearer \(authenticationToken)"
        mutableRequest.setValue(bearerTokenHeader, forHTTPHeaderField: "Authorization")
        return mutableRequest
    }

}
