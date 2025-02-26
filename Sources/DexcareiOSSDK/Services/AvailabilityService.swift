// Created by Matt Kiazyk on 2022-09-26.
// Copyright © 2022 Dexcare. All rights reserved.

import Foundation

// sourcery: AutoMockable, ProtocolPromiseExtension
/// Base Protocol to create, setup, cancel Virtual Visits
public protocol AvailabilityService {
    // sourcery: StubName=getProviderAvailabilityByDepartmentIds, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - departmentIds: An array of department Identifiers to filter availability on
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - success: A closure called with a `ProviderAvailabilityResults` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailability(departmentIds: [String], options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getProviderAvailabilityByDepartmentIdsAsync, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - departmentIds: An array of department Identifiers to filter availability on
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderAvailabilityResults`
    func getProviderAvailability(departmentIds: [String], options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult

    // sourcery: StubName=getProviderAvailabilityByLatLng, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - latitude: Latitude of the location you would like to search
    /// - longitude: Longitude of the location you would like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - success: A closure called with a `ProviderAvailabilityResults` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailability(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getProviderAvailabilityByLatLngAsync, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - latitude: Latitude of the location you would like to search
    /// - longitude: Longitude of the location you would like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderAvailabilityResults`
    func getProviderAvailability(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult

    // sourcery: StubName=getProviderAvailabilityByZipCode, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - zipCode: 5 digit zip code of the location you'd like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - success: A closure called with a `ProviderAvailabilityResults` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailability(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getProviderAvailabilityByZipCodeAsync, SkipPromiseExtension
    /// Search for available providers
    /// - Parameters:
    /// - zipCode: 5 digit zip code of the location you'd like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An optional list of `ProviderAvailabilityOptions` to filter on
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderAvailabilityResults`
    func getProviderAvailability(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult

    // MARK: AvailabilitySlots

    // sourcery: StubName=getProviderAvailabilitySlotsByDepartmentIdsAsync, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - departmentIds: An array of department Identifiers to filter availability slots on
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderSlotAvailability`
    func getProviderAvailabilitySlots(departmentIds: [String], options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability

    // sourcery: StubName=getProviderAvailabilitySlotsByDepartmentIds, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - departmentIds: An array of department Identifiers to filter availability slots on
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - success: A closure called with a `ProviderSlotAvailability` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailabilitySlots(departmentIds: [String], options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getProviderAvailabilitySlotsByZipCodeAsync, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - zipCode: 5 digit zip code of the location you'd like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderSlotAvailability`
    func getProviderAvailabilitySlots(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability

    // sourcery: StubName=getProviderAvailabilitySlotsByZipCode, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - zipCode: 5 digit zip code of the location you'd like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - success: A closure called with a `ProviderSlotAvailability` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailabilitySlots(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void)

    // sourcery: StubName=getProviderAvailabilitySlotsByLatLngAsync, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - latitude: Latitude of the location you would like to search
    /// - longitude: Longitude of the location you would like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - Throws: `FailedReason`
    /// - Returns: `ProviderSlotAvailability`
    func getProviderAvailabilitySlots(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability

    // sourcery: StubName=getProviderAvailabilitySlotsByLatLng, SkipPromiseExtension
    /// Search for provider aggregated time slots
    /// - Parameters:
    /// - latitude: Latitude of the location you would like to search
    /// - longitude: Longitude of the location you would like to search
    /// - radius: An optional radius around the location you would like to search in miles. Minimum is 1. Maximum is 100
    /// - options: An list of `ProviderAvailabilityOptions` to filter on. Note: `ProviderAvailabilityOptions.visitTypeNames` is required.
    /// - success: A closure called with a `ProviderSlotAvailability` object
    /// - failure: A closure called if any FailedReason errors are returned
    func getProviderAvailabilitySlots(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void)
}

class AvailabilityServiceSDK: AvailabilityService {
    let dexcareConfiguration: DexcareConfiguration

    let routes: Routes
    var asyncNetworkService: AsyncNetworkService

    var asyncErrorHandlers: [AsyncNetworkErrorHandler] = [] {
        didSet {
            self.asyncNetworkService.asyncErrorHandlers = asyncErrorHandlers
        }
    }

    struct Routes {
        let dexcareRoute: DexcareRoute

        func getProviderAvailability() -> URLRequest {
            return dexcareRoute.fhirBuilder.post("/v1/availability/providers")
        }

        func getProviderAvailabilitySlots() -> URLRequest {
            return dexcareRoute.fhirBuilder.post("/v1/availability/slots")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
    }

    // MARK: Get Provider availability By Department

    func getProviderAvailability(departmentIds: [String], options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerAvailability = try await getProviderAvailability(departmentIds: departmentIds, options: options)
                success(providerAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailability(departmentIds: [String], options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult {
        let request = try ProviderAvailabilityRequest(departmentIds: departmentIds, options: options)
        return try await getProviderAvailability(providerAvailabilityRequest: request)
    }

    // MARK: Get Provider availability By Lat/Lng

    func getProviderAvailability(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerAvailability = try await getProviderAvailability(latitude: latitude, longitude: longitude, radius: radius, options: options)
                success(providerAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailability(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult {
        let request = try ProviderAvailabilityRequest(latitude: latitude, longitude: longitude, radius: radius, options: options)
        return try await getProviderAvailability(providerAvailabilityRequest: request)
    }

    // MARK: Get Provider availability By ZipCode

    func getProviderAvailability(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions?, success: @escaping (ProviderAvailabilityResult) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerAvailability = try await getProviderAvailability(zipCode: zipCode, radius: radius, options: options)
                success(providerAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailability(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions?) async throws -> ProviderAvailabilityResult {
        let request = try ProviderAvailabilityRequest(postalCode: zipCode, radius: radius, options: options)
        return try await getProviderAvailability(providerAvailabilityRequest: request)
    }

    func getProviderAvailability(providerAvailabilityRequest: ProviderAvailabilityRequest) async throws -> ProviderAvailabilityResult {
        do {
            try providerAvailabilityRequest.isValid()
        } catch {
            if let message = error as? String {
                throw FailedReason.invalidInput(message: message)
            } else {
                throw FailedReason.from(error: error)
            }
        }

        let urlRequest = routes.getProviderAvailability().body(json: providerAvailabilityRequest)

        let requestTask = Task { () -> ProviderAvailabilityResult in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not search provider availability: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(providerAvailability):
            return providerAvailability
        }
    }
}

// MARK: GetProviderAvailabilitySlots

extension AvailabilityServiceSDK {
    func getProviderAvailabilitySlots(departmentIds: [String], options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerSlotAvailability = try await getProviderAvailabilitySlots(departmentIds: departmentIds, options: options)
                success(providerSlotAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailabilitySlots(departmentIds: [String], options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability {
        let request = try ProviderAvailabilityRequest(departmentIds: departmentIds, options: options)
        return try await getProviderAvailabilitySlots(providerAvailabilityRequest: request)
    }

    func getProviderAvailabilitySlots(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerSlotAvailability = try await getProviderAvailabilitySlots(zipCode: zipCode, radius: radius, options: options)
                success(providerSlotAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailabilitySlots(zipCode: String, radius: Int?, options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability {
        let request = try ProviderAvailabilityRequest(postalCode: zipCode, radius: radius, options: options)
        return try await getProviderAvailabilitySlots(providerAvailabilityRequest: request)
    }

    func getProviderAvailabilitySlots(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions, success: @escaping (ProviderSlotAvailability) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerSlotAvailability = try await getProviderAvailabilitySlots(latitude: latitude, longitude: longitude, radius: radius, options: options)
                success(providerSlotAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getProviderAvailabilitySlots(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions) async throws -> ProviderSlotAvailability {
        let request = try ProviderAvailabilityRequest(latitude: latitude, longitude: longitude, radius: radius, options: options)
        return try await getProviderAvailabilitySlots(providerAvailabilityRequest: request)
    }

    func getProviderAvailabilitySlots(providerAvailabilityRequest: ProviderAvailabilityRequest) async throws -> ProviderSlotAvailability {
        do {
            try providerAvailabilityRequest.isValid(forSlots: true)
        } catch {
            if let message = error as? String {
                throw FailedReason.invalidInput(message: message)
            } else {
                throw FailedReason.from(error: error)
            }
        }

        let urlRequest = routes.getProviderAvailabilitySlots().body(json: providerAvailabilityRequest)

        let requestTask = Task { () -> SlotAvailabilityResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not search provider slots: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(providerAvailabilitySlots):
            let availability = ProviderSlotAvailability(withInternalResponse: providerAvailabilitySlots)
            return availability
        }
    }
}
