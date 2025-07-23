// Copyright © 2021 DexCare. All rights reserved.

import Foundation

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

    /// Fetches the `VirtualPractice` information for a specific id
    ///
    /// `VirtualPractices` replace `Regions` going forward.
    ///
    /// - Parameter practiceId: the id of the `VirtualPractice` to fetch information about
    /// - Throws: `FailedReason`
    /// - Returns:`VirtualPractice` information
    func getVirtualPractice(practiceId: String) async throws -> VirtualPractice
    
    /// Fetches the WaitTimes and Availabilities of a region
    ///
    /// If no extra parameters are passed in to filter on, all `WaitTimeAvailability` are returned, including any that are currently not available.
    /// - Parameters:
    ///   - regionId: A string for the id of the selected region
    ///   - assignmentQualifiers: An optional array of `VirtualVisitAssignmentQualifier` to filter the results on
    ///   - visitTypeNames: An optional array of `VirtualVisitType` representing VisitTypeNames to filter the results on
    ///   - practiceId: A `VirtualPractice.practiceId` to filter the results on
    ///   - homeMarket: A string to filter the results for a homeMarket
    /// - Throws: `FailedReason`
    /// - Returns: `WaitTimeAvailability
    func getRegionWaitTimeAvailability(regionId: String, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?, success: @escaping ([WaitTimeAvailability]) -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Fetches the WaitTimes and Availabilities of a region
    ///
    /// If no extra parameters are passed in to filter on, all `WaitTimeAvailability` are returned, including any that are currently not available.
    /// - Parameters:
    ///   - regionId: A string for the id of the selected region
    ///   - assignmentQualifiers: An optional array of `VirtualVisitAssignmentQualifier` to filter the results on
    ///   - visitTypeNames: An optional array of `VirtualVisitType` representing VisitTypeNames to filter the results on
    ///   - practiceId: A `VirtualPractice.practiceId` to filter the results on
    ///   - homeMarket: A string to filter the results for a homeMarket
    /// - Throws: `FailedReason`
    /// - Returns: `WaitTimeAvailability` array
    func getRegionWaitTimeAvailability(regionId: String, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?) async throws -> [WaitTimeAvailability]

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
        
        func getRegionWaitTimeAvailability(regionId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/regions/\(regionId)/waittimes")
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
    
    func getRegionWaitTimeAvailability(regionId: String, assignmentQualifiers: [VirtualVisitAssignmentQualifier]? = nil, visitTypeNames: [VirtualVisitTypeName]? = nil, practiceId: String? = nil, homeMarket: String? = nil, success: @escaping ([WaitTimeAvailability]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let waitTimeAvailabilityRegion = try await getRegionWaitTimeAvailability(regionId: regionId, assignmentQualifiers: assignmentQualifiers, visitTypeNames: visitTypeNames, practiceId: practiceId, homeMarket: homeMarket)
                success(waitTimeAvailabilityRegion)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getRegionWaitTimeAvailability(regionId: String, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?) async throws -> [WaitTimeAvailability] {
        var options: [URLQueryItem] = []

        assignmentQualifiers?.forEach { assignmentQualifier in
            options.append(URLQueryItem(name: "assignmentQualifiers[]", value: assignmentQualifier.rawValue))
        }

        visitTypeNames?.forEach { visitTypeName in
            options.append(URLQueryItem(name: "visitTypeNames[]", value: visitTypeName.rawValue))
        }

        if let practiceId = practiceId {
            options.append(URLQueryItem(name: "practiceId", value: practiceId))
        }

        if let homeMarket = homeMarket {
            options.append(URLQueryItem(name: "homeMarket", value: homeMarket))
        }

        let urlRequest = routes.getRegionWaitTimeAvailability(regionId: regionId).queryItems(options)
        let requestTask = Task { () -> [WaitTimeAvailability] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not load wait time availability: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["URL": urlRequest.url?.absoluteString ?? "unknown"])
            throw FailedReason.from(error: error)
        case let .success(waitTimeAvailability):
            return waitTimeAvailability
        }
    }
}
