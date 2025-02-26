import Foundation
import UIKit

/// A service that speaks to a remote resource via URL requests
protocol AsyncNetworkService: AnyObject {
    var authenticationToken: String { get set }

    /// If this is set, all network requests made through this service will have the modifier applied.
    /// To apply multiple mutations to each network request, use `CompositeNetworkRequestModifier`.
    var requestModifiers: [NetworkRequestModifier] { get set }

    var asyncErrorHandlers: [AsyncNetworkErrorHandler] { get set }

    /// Requests data. This function handles setting up the network request, etc. All subsequent functions build off of this one.
    /// This is the only function that really needs to be implemented to provide a new instance of a network service.
    func requestData(_ request: ConvertsToURLRequest, validators: [ResponseValidator]) async throws -> (Data, URLResponse)
}

/// A helper generic struct used in Notifications.
/// A `Notification.name` is a UUID String
struct NetworkNotification {
    let name: String = UUID().uuidString

    /// A NSNotification.Name type used in Swift notifications
    var notificationName: NSNotification.Name {
        return NSNotification.Name(rawValue: name)
    }
}

struct TaskComplete {
    let response: HTTPURLResponse?
    let elapsedTime: TimeInterval?
}

var networkRequestObserverStartDateKey: UInt8 = 0

// MARK: - URL Session task did start

let networkTaskDidStartNotification: NetworkNotification = .init()
let networkTaskDidCompleteNotification: NetworkNotification = .init()

////
func postNotification<T>(notification: NetworkNotification, value: T) {
    let userInfo = ["value": UserInfoContainer(value)]
    NotificationCenter.default.post(name: notification.notificationName, object: nil, userInfo: userInfo)
}

protocol AsyncNetworkErrorHandler {
    func canHandle(_ error: Error) -> Bool
    func handle(_ error: Error) async throws
}

class AsyncHTTPNetworkService: AsyncNetworkService, BearerTokenAware {
    var refreshTokenObserver: NotificationObserver?
    var authenticationToken: String = ""
    var requestModifiers: [NetworkRequestModifier]

    public var asyncErrorHandlers: [AsyncNetworkErrorHandler] = []

    #if DEBUG
        // In order for playground to work with Charles, we need to override authenticationChallenge
        // Note this is ONLY for DEBUG
        private static let enabler = NetworkEnabler()
        private let urlSession = URLSession(configuration: .default, delegate: AsyncHTTPNetworkService.enabler, delegateQueue: nil)
    #else
        private let urlSession = URLSession(configuration: .ephemeral)

    #endif

    public init(requestModifiers: [NetworkRequestModifier] = []) {
        self.requestModifiers = requestModifiers

        refreshTokenObserver = NotificationObserver(notification: refreshTokenNotification) { [weak self] token in
            self?.authenticationToken = token
        }
    }

    private func applyModifiers(to request: ConvertsToURLRequest) -> URLRequest {
        let updatedRequest = requestModifiers.reduce(request.asURLRequest()) { previousRequest, modifier in
            return modifier.mutate(previousRequest)
        }
        // if we've set the authorization header lets update it with the new one that got sent back from the client
        // if not, return the regular request
        if updatedRequest.allHTTPHeaderFields?["Authorization"] != nil {
            return updatedRequest.token(authenticationToken) // for all calls, for simplicity - lets add the bearer token
        } else {
            return updatedRequest
        }
    }

    func safeRequest<T>(requestBuilder: @escaping () async throws -> T) async throws -> T {
        do {
            return try await requestBuilder()
        } catch {
            guard let asyncErrorHandler = self.asyncErrorHandlers.filter({ $0.canHandle(error) }).first else {
                throw error
            }

            try await asyncErrorHandler.handle(error)
            return try await requestBuilder()
        }
    }

    func requestData(_ request: ConvertsToURLRequest, validators: [ResponseValidator]) async throws -> (Data, URLResponse) {
        return try await safeRequest {
            let modifiedRequest = self.applyModifiers(to: request)

            let dataTask = Task { () -> (Data?, URLResponse) in
                return try await self.urlSession.data(for: modifiedRequest)
            }

            let result = await dataTask.result

            switch result {
            case let .failure(error):
                throw error
            case let .success((data, response)):
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.invalidResponseFormat
                }

                for validate in validators {
                    try validate(response, data)
                }

                guard let data = data else {
                    throw NetworkError.noDataInResponse
                }

                return (data, response)
            }
        }
    }
}

extension AsyncNetworkService {
    /// Requests a single object. That object must conform to `Decodable`. Will interpret the data received as JSON and attempt to decode the object in question from it.
    func requestObject<ObjectType: Decodable>(_ request: ConvertsToURLRequest, validators: [ResponseValidator] = [statusCodeIsIn200s], jsonDecoder: JSONDecoder = JSONDecoder.networkJSONDecoder) async throws -> ObjectType {
        let requestTask = Task { () -> (Data, URLResponse) in
            return try await requestData(request, validators: validators)
        }

        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error

        case let .success((data, _)):
            do {
                return try jsonDecoder.decode(ObjectType.self, from: data)
            } catch {
                throw NetworkError.decoding(error: error)
            }
        }
    }

    /// Requests a string from a network endpoint.
    func requestString(_ request: ConvertsToURLRequest, encoding: String.Encoding = .utf8, validators: [ResponseValidator] = [statusCodeIsIn200s]) async throws -> String {
        let requestTask = Task { () -> (Data, URLResponse) in
            return try await requestData(request, validators: validators)
        }

        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error

        case let .success((data, _)):
            guard let string = String(data: data, encoding: encoding) else {
                throw NetworkError.decodingString
            }
            return string
        }
    }

    /// Requests a network endpoint without any return
    func requestVoid(_ request: ConvertsToURLRequest, validators: [ResponseValidator] = [statusCodeIsIn200s]) async throws {
        let requestTask = Task { () -> (Data, URLResponse) in
            return try await requestData(request, validators: validators)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            throw error
        case .success:
            // can ignore if successful
            return
        }
    }
}

#if DEBUG
    // In order for playground to work with Charles, we need to override authenticationChallenge
    class NetworkEnabler: NSObject, URLSessionDelegate {
        public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
            completionHandler(.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
        }
    }
#endif

extension JSONDecoder {
    static let networkJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601 // does not handle fractional seconds
        return decoder
    }()
}
