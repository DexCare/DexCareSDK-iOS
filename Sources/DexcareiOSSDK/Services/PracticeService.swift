// Copyright © 2021 DexCare. All rights reserved.

import Foundation

// sourcery: AutoMockable, ProtocolPromiseExtension
/// Base Protocol to get Virtual Practice Information
public protocol PracticeService {
    /// Fetches the `VirtualPractice` information for a specific id
    ///
    /// `VirtualPractices` replace `Regions` going forward.
    ///
    /// - Parameter practiceId: the id of the `VirtualPractice` to fetch information about
    /// - Parameter success: A closure called with the `VirtualPractice` information
    /// - Parameter failure: A closure called if any FailedReason errors are returned
    func getVirtualPractice(practiceId: String, success: @escaping (VirtualPractice) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getVirtualPracticeAsync, SkipPromiseExtension
    /// Fetches the `VirtualPractice` information for a specific id
    ///
    /// `VirtualPractices` replace `Regions` going forward.
    ///
    /// - Parameter practiceId: the id of the `VirtualPractice` to fetch information about
    /// - Throws: `FailedReason`
    /// - Returns:`VirtualPractice` information
    func getVirtualPractice(practiceId: String) async throws -> VirtualPractice
}

class PracticeServiceSDK: PracticeService {
    // a helper property for tests so we can override the token
    var authenticationToken: String {
        get {
            return self.asyncNetworkService.authenticationToken
        }
        set {
            self.asyncNetworkService.authenticationToken = newValue
        }
    }

    var asyncErrorHandlers: [AsyncNetworkErrorHandler] = [] {
        didSet {
            self.asyncNetworkService.asyncErrorHandlers = asyncErrorHandlers
        }
    }

    let dexcareConfiguration: DexcareConfiguration
    let routes: Routes
    var asyncNetworkService: AsyncNetworkService

    struct Routes {
        let dexcareRoute: DexcareRoute

        // MARK: Practices

        func getPractice(practiceId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/practices/\(practiceId)")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.authenticationToken = ""
    }

    func getVirtualPractice(practiceId: String, success: @escaping (VirtualPractice) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let practice = try await getVirtualPractice(practiceId: practiceId)
                success(practice)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getVirtualPractice(practiceId: String) async throws -> VirtualPractice {
        if practiceId.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "practiceId must not be empty"))
            throw FailedReason.missingInformation(message: "practiceId must not be empty")
        }

        let urlRequest = routes.getPractice(practiceId: practiceId)
        let requestTask = Task { () -> VirtualPractice in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get virtual practice info: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["practiceId": practiceId])
            throw FailedReason.from(error: error)
        case let .success(virtualPractice):
            return virtualPractice
        }
    }
}
