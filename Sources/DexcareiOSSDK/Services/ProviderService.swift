//
// ProviderService.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2021-01-11.
// Copyright © 2021 DexCare. All rights reserved.
//

import Foundation

/// Base Protocol to retrieve information about providers, and schedule provider visits
public protocol ProviderService {
    
    /// Fetches information about a specified health-care provider.
    ///
    /// - Parameter providerNationalId: The national identifier of the provider to retrieve information about. This identifier should be retrieved from a source external to DexCare, specific to your health system.
    /// - Parameter success: A closure called with the `Provider` information
    /// - Parameter failure: A closure called if any FailedReason errors are returned
    func getProvider(providerNationalId: String, success: @escaping (Provider) -> Void, failure: @escaping (FailedReason) -> Void)
        
    /// Fetches upcoming available time slots for a given provider.
    ///
    /// - Parameter providerNationalId: The national identifier of the provider to retrieve information about. This identifier should be retrieved from a source external to DexCare, specific to your health system.
    /// - Parameter visitTypeShortName: A shortName of the visitType for which you are retrieving `ProviderTimeSlot` for. See `ProviderVisitType`
    /// - Parameter startDate - The start date for the range of time slots to return. **Note:** `startDate` must be at least Today. If nil is passed in, the SDK will default to Today.
    /// - Parameter endDate - The end date for the range of time slots to return. **Note:** `endDate` must be at >= `startDate`. If nil is passed in, the SDK will default to Today + 7 days ahead
    /// - Parameter success: A closure called with the `ProviderTimeSlot` information
    /// - Parameter failure: A closure called if any FailedReason errors are returned
    func getProviderTimeSlots(providerNationalId: String, visitTypeShortName: VisitTypeShortName, startDate: Date?, endDate: Date?, success: @escaping (ProviderTimeSlot) -> Void, failure: @escaping (FailedReason) -> Void)
        
    /// Fetches the maximum number of days beyond Today that `getProviderTimeSlots` can return results for.
    ///
    /// - Parameter visitTypeShortName: The `shortName` of the `ProviderVisitType` to check the max lookahead days for.
    /// - Parameter ehrSystemName The name of the EHR system in which the max lookahead days should be checked. This can be determined based on the `ProviderDepartment` that a visit will potentially be booked to.
    /// - Parameter success: A closure called with the maximum number of days beyond Today that `getProviderTimeSlots` can return results for. The SDK will not use this value internally, but is for you to use for the `endDate` property of `getProviderTimeSlots`.
    /// - Parameter failure: A closure called if any FailedReason errors are returned
    func getMaxLookaheadDays(visitTypeShortName: VisitTypeShortName, ehrSystemName: String, success: @escaping (Int) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Schedules a visit with a Provider.
    ///
    /// - Parameter paymentMethod: A `PaymentMethod` enum containing the patient's payment information
    /// - Parameter providerVisitInformation: A `ProviderVisitInformation`]` object containing additional details required to schedule the appointment.
    /// - Parameter timeSlot: A `TimeSlot` that the user is requesting to schedule the appointment in. TimeSlots are returned by `getProviderTimeSlots`.
    /// - Parameter ehrSystemName: The EHR system the appointment will be scheduled in. This can be determined based on the Provider's `ProviderDepartment` ehrSystemName property.
    /// - Parameter patientDexCarePatient:A `DexCarePatient` object containing demographics information about the patient.
    /// - Parameter actorDexCarePatient: Optional, a `DexCarePatient` object containing information about a parent or app user who's booking the visit for someone else. This is only used when `ProviderVisitInformation.patientDeclaration` is `.other`
    /// - Parameter success: A closure called with the `ScheduledProviderVisit` structure containing information of the visit
    /// - Parameter failure: A closure called if any `ScheduleProviderAppointmentFailedReason` errors are returned
    func scheduleProviderVisit(paymentMethod: PaymentMethod, providerVisitInformation: ProviderVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, patientDexCarePatient: DexcarePatient, actorDexCarePatient: DexcarePatient?, success: @escaping (ScheduledProviderVisit) -> Void, failure: @escaping (ScheduleProviderAppointmentFailedReason) -> Void)
    
    // Async
    /// Fetches information about a specified health-care provider.
    ///
    /// - Parameter providerNationalId: The national identifier of the provider to retrieve information about. This identifier should be retrieved from a source external to DexCare, specific to your health system.
    /// - Throws:`FailedReason`
    /// - Returns:`Provider` information
    func getProvider(providerNationalId: String) async throws -> Provider
    
    /// Fetches upcoming available time slots for a given provider.
    ///
    /// - Parameter providerNationalId: The national identifier of the provider to retrieve information about. This identifier should be retrieved from a source external to DexCare, specific to your health system.
    /// - Parameter visitTypeShortName: A shortName of the visitType for which you are retrieving `ProviderTimeSlot` for. See `ProviderVisitType`
    /// - Parameter startDate - The start date for the range of time slots to return. **Note:** `startDate` must be at least Today. If nil is passed in, the SDK will default to Today.
    /// - Parameter endDate - The end date for the range of time slots to return. **Note:** `endDate` must be at >= `startDate`. If nil is passed in, the SDK will default to Today + 7 days ahead
    /// - Throws:`FailedReason`
    /// - Returns:`ProviderTimeSlot` information
    func getProviderTimeSlots(providerNationalId: String, visitTypeShortName: VisitTypeShortName, startDate: Date?, endDate: Date?) async throws -> ProviderTimeSlot
    
    /// Fetches the maximum number of days beyond Today that `getProviderTimeSlots` can return results for.
    ///
    /// - Parameter visitTypeShortName: The `shortName` of the `ProviderVisitType` to check the max lookahead days for.
    /// - Parameter ehrSystemName The name of the EHR system in which the max lookahead days should be checked. This can be determined based on the `ProviderDepartment` that a visit will potentially be booked to.
    /// - Throws:`FailedReason`
    /// - Returns: The maximum number of days beyond Today that `getProviderTimeSlots` can return results for. The SDK will not use this value internally, but is for you to use for the `endDate` property of `getProviderTimeSlots`.
    func getMaxLookaheadDays(visitTypeShortName: VisitTypeShortName, ehrSystemName: String) async throws -> Int
    
    /// Schedules a visit with a Provider.
    ///
    /// - Parameters:
    ///   - paymentMethod: A `PaymentMethod` enum containing the patient's payment information
    ///   - providerVisitInformation: A `ProviderVisitInformation`]` object containing additional details required to schedule the appointment.
    ///   - timeSlot: A `TimeSlot` that the user is requesting to schedule the appointment in. TimeSlots are returned by `getProviderTimeSlots`.
    ///   - ehrSystemName: The EHR system the appointment will be scheduled in. This can be determined based on the Provider's `ProviderDepartment` ehrSystemName property.
    ///   - patientDexCarePatient:A `DexCarePatient` object containing demographics information about the patient.
    ///   - actorDexCarePatient: Optional, a `DexCarePatient` object containing information about a parent or app user who's booking the visit for someone else. This is only used when `ProviderVisitInformation.patientDeclaration` is `.other`
    /// - Throws:`ScheduleProviderAppointmentFailedReason`
    /// - Returns: The `ScheduledProviderVisit` structure containing information of the visit
    func scheduleProviderVisit(paymentMethod: PaymentMethod, providerVisitInformation: ProviderVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, patientDexCarePatient: DexcarePatient, actorDexCarePatient: DexcarePatient?) async throws -> ScheduledProviderVisit
}

internal protocol InternalProviderService {
    var customizationOptions: CustomizationOptions? { get set }
}

class ProviderServiceSDK: ProviderService, InternalProviderService {

    var customizationOptions: CustomizationOptions?
    
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
    var defaultDaysAhead: Int = 7
    
    struct Routes {
        let dexcareRoute: DexcareRoute
        
        // MARK: Provider
        func getProvider(nationalId: String) -> URLRequest {
            return dexcareRoute.fhirBuilder.get("v1/providers/\(nationalId)")
        }
        func getProviderTimeSlots(nationalId: String) -> URLRequest {
            return dexcareRoute.fhirBuilder.get("v4/providers/\(nationalId)/timeslots")
        }
        func getMaxLookAhead() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("v2/lookups/maxLookaheadDays")
        }
        func bookAppointment() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/7/visits/providerbooking")
        }
    }
    
    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.authenticationToken = ""
    }
    
    func getProvider(providerNationalId: String, success: @escaping (Provider) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let provider = try await getProvider(providerNationalId: providerNationalId)
                success(provider)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getProvider(providerNationalId: String) async throws -> Provider {
        if providerNationalId.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "providerNationalId must not be empty"))
            throw FailedReason.missingInformation(message: "providerNationalId must not be empty")
        }
        
        let urlRequest = routes.getProvider(nationalId: providerNationalId)
        
        let requestTask = Task { () -> Provider in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get provider info: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["providerNationalId": providerNationalId])
            throw FailedReason.from(error: error)
        case .success(let provider):
            return provider
        }
    }
    
    func getProviderTimeSlots(providerNationalId: String, visitTypeShortName: VisitTypeShortName, startDate: Date?, endDate: Date?, success: @escaping (ProviderTimeSlot) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let practice = try await getProviderTimeSlots(providerNationalId: providerNationalId, visitTypeShortName: visitTypeShortName, startDate: startDate, endDate: endDate)
                success(practice)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getProviderTimeSlots(providerNationalId: String, visitTypeShortName: VisitTypeShortName, startDate: Date?, endDate: Date?) async throws -> ProviderTimeSlot {
        if providerNationalId.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "providerNationalId must not be empty"))
            throw FailedReason.missingInformation(message: "providerNationalId must not be empty")
        }
        if visitTypeShortName.rawValue.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "visitTypeShortName must not be empty"))
            throw FailedReason.missingInformation(message: "visitTypeShortName must not be empty")
        }
        
        var updatedStartDate = Date() // default to today
        if let startDate = startDate {
            updatedStartDate = startDate
        }
        // check that updatedStartDate < today
        if Date().daysFrom(updatedStartDate) < 0 {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.invalidInput(message: "startDate must be at least today"))
            throw FailedReason.invalidInput(message: "startDate must be at least today")
        }
        
        var updatedEndDate: Date
        if let endDate = endDate {
            updatedEndDate = endDate
        } else {
            // we don't have an endDate, lets push it forward
            updatedEndDate = Calendar.current.date(byAdding: .day, value: defaultDaysAhead, to: Date()) ?? Date()
        }
        
        // check if endDate < startDate
        if updatedEndDate < updatedStartDate {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.invalidInput(message: "endDate must not be before startDate"))
            throw FailedReason.invalidInput(message: "endDate must not be before startDate")
        }
        
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "startDate", value: DateFormatter.yearMonthDay.string(from: updatedStartDate)),
            URLQueryItem(name: "endDate", value: DateFormatter.yearMonthDay.string(from: updatedEndDate)),
            URLQueryItem(name: "visitType", value: visitTypeShortName.rawValue)
        ]
        
        let urlRequest = routes.getProviderTimeSlots(nationalId: providerNationalId).queryItems(queryItems)
        
        let requestTask = Task { () -> ProviderTimeSlot in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get provider time slots: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["providerNationalId": providerNationalId, "visitTypeShortName": visitTypeShortName.rawValue])
            throw FailedReason.from(error: error)
        case .success(let timeSlot):
            return timeSlot
        }
    }
        
    func getMaxLookaheadDays(visitTypeShortName: VisitTypeShortName, ehrSystemName: String, success: @escaping (Int) -> Void, failure: @escaping (FailedReason) -> Void) {

        Task { @MainActor in
            do {
                let days = try await getMaxLookaheadDays(visitTypeShortName: visitTypeShortName, ehrSystemName: ehrSystemName)
                success(days)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getMaxLookaheadDays(visitTypeShortName: VisitTypeShortName, ehrSystemName: String) async throws -> Int {
        if visitTypeShortName.rawValue.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "visitTypeShortName must not be empty"))
            throw FailedReason.missingInformation(message: "visitTypeShortName must not be empty")
        }
        
        if ehrSystemName.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "ehrSystemName must not be empty"))
            throw FailedReason.missingInformation(message: "ehrSystemName must not be empty")
        }
        
        let urlRequest = routes.getMaxLookAhead().queryItems([
            "visitTypeName": visitTypeShortName.rawValue,
            "epicInstanceName": ehrSystemName
        ])
        
        let requestTask = Task { () -> MaxLookaheadDayResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get max lookahead days: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitTypeShortName": visitTypeShortName.rawValue, "ehrSystemName": ehrSystemName])
            throw FailedReason.from(error: error)
        case .success(let response):
            return response.maxLookaheadDays
        }
    }
    func scheduleProviderVisit(paymentMethod: PaymentMethod, providerVisitInformation: ProviderVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, patientDexCarePatient: DexcarePatient, actorDexCarePatient: DexcarePatient?, success: @escaping (ScheduledProviderVisit) -> Void, failure: @escaping (ScheduleProviderAppointmentFailedReason) -> Void) {
        Task { @MainActor in
            do {
                let providerVisit = try await scheduleProviderVisit(
                    paymentMethod: paymentMethod,
                    providerVisitInformation: providerVisitInformation,
                    timeSlot: timeSlot,
                    ehrSystemName: ehrSystemName,
                    patientDexCarePatient: patientDexCarePatient,
                    actorDexCarePatient: actorDexCarePatient
                )
                success(providerVisit)
            } catch let error as ScheduleProviderAppointmentFailedReason {
                failure(error)
            }
        }
    }
    
    func scheduleProviderVisit(paymentMethod: PaymentMethod, providerVisitInformation: ProviderVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, patientDexCarePatient: DexcarePatient, actorDexCarePatient: DexcarePatient?) async throws -> ScheduledProviderVisit {
        if ehrSystemName.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "ehrSystemName must not be empty"))
            throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "ehrSystemName must not be empty")
        }
        
        let request: ScheduleProviderAppointmentRequest!
        do {
            request = try ScheduleProviderAppointmentRequest(
                billingInfo: BillingInformation(paymentMethod: paymentMethod),
                visitInfo: providerVisitInformation,
                timeSlot: timeSlot,
                ehrSystemName: ehrSystemName,
                dexcarePatient: patientDexCarePatient,
                actorPatient: actorDexCarePatient,
                customization: customizationOptions,
                logger: dexcareConfiguration.logger
            )
        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["patientGuid": patientDexCarePatient.patientGuid])
            throw (error as? ScheduleProviderAppointmentFailedReason ?? ScheduleProviderAppointmentFailedReason.from(error: error))
        }
        
        let urlRequest = routes.bookAppointment().body(json: request).token(authenticationToken)
        
        let requestTask = Task { () -> ScheduledProviderVisit in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not save provider visit: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["patientGuid": patientDexCarePatient.patientGuid])
            throw ScheduleProviderAppointmentFailedReason.from(error: error)
        case .success(let appointmentResponse):
            return appointmentResponse
        }
    }
}

extension ScheduleProviderAppointmentRequest {
    
    init?(billingInfo: BillingInformation, visitInfo: ProviderVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, dexcarePatient: DexcarePatient, actorPatient: DexcarePatient?, customization: CustomizationOptions? = CustomizationOptions(validateEmails: false), logger: DexcareSDKLogger?) throws {
        var patient: Patient
        var actor: Actor?
        
        if !PhoneValidator.isValid(phoneNumber: visitInfo.contactPhoneNumber) {
            throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "DexcareSDK Error: contactPhoneNumber is invalid")
        }
        let contactPhoneNumber = PhoneValidator.removeNonDecimalCharacters(visitInfo.contactPhoneNumber)
        
        if customization?.validateEmails ?? true {
            if !EmailValidator.isValid(email: visitInfo.userEmail) {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "DexcareSDK Error: userEmail is invalid")
            }
        } else {
            logger?.log("Skipping Email Validation check - customization option is false")
        }
        
        switch visitInfo.patientDeclaration {
            // If the declaration was "self" then patient is the logged in user and there is no actor
        case .self:
            guard let patientDemographics = dexcarePatient.demographics(from: ehrSystemName) else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Patient is missing demographics in \(ehrSystemName)")
            }
            
            guard let address = patientDemographics.addresses.first else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Patient is missing an address")
            }
            
            do {
                try address.validate()
            } catch {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: String(describing: error))
            }
            
            patient = Patient(
                patientGuid: dexcarePatient.patientGuid,
                address: address
            )
            
            actor = nil
            
            // If the declaration was "other" then the dependent is the patient and the logged in user is the actor
        case .other:
            
            guard let dependentDemographics = dexcarePatient.demographics(from: ehrSystemName) else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Patient is missing demographics in \(ehrSystemName)")
            }
            guard let dependentAddress = dependentDemographics.addresses.first else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Patient is missing an address")
            }
            guard let actorPatient = actorPatient else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Actor is missing")
            }
            guard let actorDemographics = actorPatient.demographicsLinks.first else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "Actor is missing demographics")
            }
            
            guard let actorRelationshipToPatient = visitInfo.actorRelationshipToPatient else {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: "ProviderVisitInformation.actorRelationshipToPatient is not set")
            }
            
            do {
                try dependentAddress.validate()
            } catch {
                throw ScheduleProviderAppointmentFailedReason.missingInformation(message: String(describing: error))
            }
            
            patient = Patient(
                patientGuid: dexcarePatient.patientGuid,
                address: dependentAddress
            )
            
            actor = Actor(
                patientGuid: actorPatient.patientGuid,
                firstName: actorDemographics.name.given,
                lastName: actorDemographics.name.family,
                phone: contactPhoneNumber,
                gender: actorDemographics.gender,
                dateOfBirth: DateFormatter.yearMonthDay.string(from: actorDemographics.birthdate),
                relationshipToPatient: actorRelationshipToPatient
            )
        }        
        
        let visitDetails = VisitDetails(
            ehrSystemName: ehrSystemName,
            departmentId: timeSlot.departmentId,
            visitReason: visitInfo.visitReason,
            declaration: visitInfo.patientDeclaration,
            slotId: timeSlot.slotId,
            nationalProviderId: timeSlot.providerNationalId,
            visitTypeId: timeSlot.visitTypeId,
            patientQuestions: visitInfo.patientQuestions,
            providerFlowPayment: true
        )
        
        self.init(
            patient: patient,
            actor: actor,
            visitDetails: visitDetails,
            billingInfo: billingInfo
        )
    }
}
