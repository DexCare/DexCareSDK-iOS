// Copyright © 2019 DexCare. All rights reserved.

import Foundation

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get    = "GET"
    case head   = "HEAD"
    case post   = "POST"
    case put    = "PUT"
    case patch  = "PATCH"
    case delete = "DELETE"
    case trace  = "TRACE"
    case connect = "CONNECT"
}

enum ContentType: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
}

// URLRequestBuilder is a simple "fluent"-style builder for constructing URLRequest objects. This api is
// intended to make it very simple to define requests with an intuitive one-liner syntax.
//
// .e.g. let builder = URLRequestBuilder()
//      builder.get("/users/\(id)/profile").request()
//      builder.post("/users").body(json: profile).setValue("1.2.1", forHeader: "X-API-Version")
//
//      let otherBuilder = URLRequestBuilder(Environment.current.someOtherBaseURL)
//      otherBuilder.get("/some/path?param=blah").withCachePolicy(.returnCacheDataElseLoad)
class URLRequestBuilder {
    internal let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }

    func get(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.get).contentType(contentType)
    }
    
    func post(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.post).contentType(contentType)
    }
    
    func put(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.put)
    }
    
    func delete(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.delete)
    }
}

extension URLRequest {
    func path(_ path: String) -> URLRequest {
        var request = self
        request.url = url?.appendingPathComponent(path)
        return request
    }
    
    func method(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }
    
    func body(json body: Encodable) -> URLRequest {
        var request = self
        request.httpBody = try? body.serializeToJSON(dateEncodingStrategy: .formatted(.iso8601Full))
        return request.contentType(.json)
    }
    
    func queryItems(_ items: [String: String]) -> URLRequest {
        var request = self
        guard let url = request.url else { return request }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let urlQueryItems = items.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        components?.append(queryItems: urlQueryItems)
        
        guard let finalURL = components?.url else { return request }
        request.url = finalURL
        return request
    }
    
    func queryItems(_ queryItems: [URLQueryItem]) -> URLRequest {
        var request = self
        guard let url = request.url else { return request }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        components?.append(queryItems: queryItems)
        
        guard let finalURL = components?.url else { return request }
        request.url = finalURL
        return request
    }
    
    func token(_ token: String) -> URLRequest {
        let bearerRequestModifier = BearerTokenRequestModifier(authenticationToken: token)
        return bearerRequestModifier.mutate(self)
    }
    
    func contentType(_ contentType: ContentType) -> URLRequest {
        return setValue(contentType.rawValue, forHeader: "Content-Type")
    }
    
    func setValue(_ value: String, forHeader header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }
}

private extension URLComponents {
    mutating func append(queryItems: [URLQueryItem]) {
        guard !queryItems.isEmpty else {
            return
        }
        self.queryItems = (self.queryItems ?? [URLQueryItem]()) + queryItems
    }
}
