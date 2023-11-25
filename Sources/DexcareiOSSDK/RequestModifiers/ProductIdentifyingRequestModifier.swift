// Copyright © 2019 Providence. All rights reserved.

import Foundation

class ProductIdentifyingRequestModifier: NetworkRequestModifier {
    
    func mutate(_ request: URLRequest) -> URLRequest {
        guard
            let url = request.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return request
        }
        
        let product = URLQueryItem(name: "product", value: "healthconnect-iOS")
        var queryItems: [URLQueryItem] = components.queryItems ?? []
        queryItems.append(product)
        components.queryItems = queryItems
        
        guard let newURL = components.url else {
            assertionFailure("Expected to be able to add a query item to the URL without breaking it")
            return request
        }
        
        var newRequest = request
        newRequest.url = newURL
        return newRequest
    }
}
