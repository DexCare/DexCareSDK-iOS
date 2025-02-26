import Foundation

protocol LoggingService {
    var visitId: String? { get set }
    var lastCorrelationId: String? { get set }
    func postMessage(message: String, data: [String: String]?)
    func postMessage(message: String)
    func postErrorIfNeeded(error: Error)
    func postErrorIfNeeded(error: Error, data: [String: String]?)
}

class LoggingServiceSDK: LoggingService {
    let routes: Routes
    let reachability = try? Reachability()

    var asyncNetworkService: AsyncNetworkService
    var visitId: String?
    var connectionType: Reachability.Connection = .unavailable
    var lastCorrelationId: String?

    struct Routes {
        let dexcareRoute: DexcareRoute

        func postLog() -> URLRequest {
            return dexcareRoute.fhirBuilder.post("/v2/clientLogging")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))

        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)

        // keep track of connection type throughout and send up on each server log
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }

        reachability?.whenReachable = { [weak self] reachability in
            self?.connectionType = reachability.connection
        }
        reachability?.whenUnreachable = { [weak self] reachability in
            self?.connectionType = reachability.connection
        }
    }

    deinit {
        reachability?.stopNotifier()
    }

    func postMessage(message: String) {
        postMessage(message: message, data: nil)
    }

    func postErrorIfNeeded(error: Error) {
        postErrorIfNeeded(error: error, data: nil)
    }

    func postMessage(message: String, data: [String: String]?) {
        let loggingRequest = LoggingRequest(message: message, visitId: visitId, connectionType: connectionType, lastCorrelationId: lastCorrelationId, data: data)
        let urlRequest = routes.postLog().body(json: loggingRequest)

        // ignore error. will be shown in network logger
        Task {
            try? await asyncNetworkService.requestVoid(urlRequest)
        }
    }

    func postErrorIfNeeded(error: Error, data: [String: String]?) {
        switch error {
        case let NetworkError.decoding(error):
            // post if there is a decoding error.
            postMessage(message: String(describing: error))
        case is NetworkError:
            // do nothing - it's a regular network error that will be logged on the server
            break
        default:
            // Not a network error so lets log in
            postMessage(message: String(describing: error), data: data)
        }
    }
}

struct LoggingRequest: Encodable {
    let message: String
    let visitId: String?
    let connectionType: Reachability.Connection?
    let lastCorrelationId: String?
    let data: [String: String]?

    static func toStringDictionary(dict: [String: Any]?) -> [String: String] {
        var converted: [String: String] = [:]

        dict?.forEach { (key: String, value: Any) in
            converted[key] = String(describing: value)
        }

        return converted
    }
}
