//
// AppointmentService.swift
// DexcareSDK
//
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// The AppointmentService provides access to a list of scheduled appointments with the logged in user, as well as functions to create appointments
public protocol AppointmentService {
    /// An asynchronous call to fetch a list of the patients retail visits that have been scheduled.
    ///
    /// Internally, this will filter the appointment based on status=requested
    /// - Parameters:
    ///   - success: A closure called when the call succeeds. A possibly empty array of `ScheduledVisit` objects is passed to the closure.
    ///   - failure: A closure called when the call fails.
    func getRetailVisits(success: @escaping ([ScheduledVisit]) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Returns a list of CancellationReason objects that will be used in `cancelRetailAppointment` call
    /// - Parameters:
    ///   - success: A closure called with a list of `CancelReason` objects
    ///   - failure: A closure called if any FailedReason errors are returned
    func getCancelReasons(brandName: String, success: @escaping ([CancelReason]) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Cancels an appointment
    /// - Parameters:
    ///   - visitId: The visit id of the `ScheduledVisit` to be cancelled
    ///   - cancelReason: Reason for cancellation selected from the `CancelReason` objects returned from `getCancelReasons(brandName:success:failure:)`
    ///   - success: A closure called if the appointment is successfully cancelled
    ///   - failure: A closure called if any FailedReason errors are returned
    func cancelRetailAppointment(visitId: String, cancelReason: CancelReason, success: @escaping () -> Void, failure: @escaping (FailedReason) -> Void)

    // Async
    /// An asynchronous call to fetch a list of the patients retail visits that have been scheduled.
    ///
    /// Internally, this will filter the appointment based on status=requested
    /// - Throws: FailedReason
    /// - Returns:An array of `ScheduledVisit` objects.
    /// - Note: The return array may be empty
    func getRetailVisits() async throws -> [ScheduledVisit]

    /// Returns a list of CancellationReason objects that will be used in `cancelRetailAppointment` call
    /// - Throws: `FailedReason`
    /// - Returns: An array of `CancelReason` objects
    func getCancelReasons(brandName: String) async throws -> [CancelReason]

    /// Cancels an appointment
    /// - Parameters:
    ///   - visitId: The visit id of the `ScheduledVisit` to be cancelled
    ///   - cancelReason: Reason for cancellation selected from the `CancelReason` objects returned from `getCancelReasons(brandName:success:failure:)`
    /// - Throws:`FailedReason`
    /// - Returns: Void - indicates the appointment is successfully cancelled
    func cancelRetailAppointment(visitId: String, cancelReason: CancelReason) async throws
}

class AppointmentServiceSDK: AppointmentService {
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

        func clinic(departmentName: String) -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v1/departments/\(departmentName)")
        }

        // MARK: Appointments

        func getRetailVisits() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("api/6/visits/retail/self")
        }

        func getCancellationReasons(brandName: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/7/visits/retail/cancel/reasons/\(brandName)")
        }

        func cancelRetailAppointment(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/6/visits/retail/cancel/\(visitId)")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))

        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.authenticationToken = ""
    }

    // MARK: - Public methods

    func getRetailVisits(success: @escaping ([ScheduledVisit]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let scheduleVisits = try await getRetailVisits()
                success(scheduleVisits)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getRetailVisits() async throws -> [ScheduledVisit] {
        // if we don't filter out just the requested, then it will return all appointments (cancelled, finished, etc)
        let urlRequest = routes.getRetailVisits().token(authenticationToken).queryItems([
            "status": "requested",
        ])

        let requestTask = Task { () -> [ScheduledVisit] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not load scheduled visits: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(scheduledVisits):
            return try await getDepartmentInfo(withScheduledVisits: scheduledVisits)
        }
    }

    func getCancelReasons(brandName: String, success: @escaping ([CancelReason]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let cancelReasons = try await getCancelReasons(brandName: brandName)
                success(cancelReasons)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getCancelReasons(brandName: String) async throws -> [CancelReason] {
        if brandName.isEmpty {
            throw FailedReason.missingInformation(message: "brandName must not be empty")
        }

        let urlRequest = routes.getCancellationReasons(brandName: brandName)

        let requestTask = Task { () -> [CancelReason] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get cancel reasons: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(cancelReasons):
            return cancelReasons
        }
    }

    func cancelRetailAppointment(visitId: String, cancelReason: CancelReason, success: @escaping () -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                try await cancelRetailAppointment(visitId: visitId, cancelReason: cancelReason)
                success()
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func cancelRetailAppointment(visitId: String, cancelReason: CancelReason) async throws {
        if visitId.isEmpty {
            throw FailedReason.missingInformation(message: "visitId must not be empty")
        }
        let cancelRequest = CancelRetailAppointmentRequestNew(reason: cancelReason.code)
        let urlRequest = routes.cancelRetailAppointment(visitId: visitId).body(json: cancelRequest).token(authenticationToken)

        let requestTask = Task { () in
            return try await asyncNetworkService.requestVoid(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not cancel appointment : \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitId": visitId])
            throw FailedReason.from(error: error)
        case .success:
            return
        }
    }

    // MARK: - Private methods

    private func getDepartmentInfo(withScheduledVisits visits: [ScheduledVisit]) async throws -> [ScheduledVisit] {
        return try await withThrowingTaskGroup(of: ScheduledVisit.self) { group in
            var scheduledVisits: [ScheduledVisit] = []
            for visit in visits {
                group.addTask {
                    return try await self.getDepartmentInfo(withScheduledVisit: visit)
                }
            }

            for try await scheduledVisit in group {
                scheduledVisits.append(scheduledVisit)
            }
            return scheduledVisits
        }
    }

    private func getDepartmentInfo(withScheduledVisit scheduledVisit: ScheduledVisit) async throws -> ScheduledVisit {
        let clinic = try await getDepartmentInfo(departmentName: scheduledVisit.departmentURLKey())
        var scheduledVisit = scheduledVisit
        scheduledVisit.retailDepartment = clinic
        return scheduledVisit
    }

    private func getDepartmentInfo(departmentName: String) async throws -> RetailDepartment {
        let urlRequest = routes.clinic(departmentName: departmentName).queryItems([
            "byId": "true",
        ])
        return try await asyncNetworkService.requestObject(urlRequest)
    }
}

extension ScheduleRetailAppointmentRequest {
    init(billingInfo: BillingInformation, visitInfo: RetailVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, dexcarePatient: DexcarePatient, actorPatient: DexcarePatient?, customization: CustomizationOptions? = CustomizationOptions.init(validateEmails: true), logger: DexcareSDKLogger?) throws {
        var patient: Patient
        var actor: Actor?

        if !PhoneValidator.isValid(phoneNumber: visitInfo.contactPhoneNumber) {
            throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "DexcareSDK Error: contactPhoneNumber is invalid")
        }
        let contactPhoneNumber = PhoneValidator.removeNonDecimalCharacters(visitInfo.contactPhoneNumber)

        if customization?.validateEmails ?? true {
            if !EmailValidator.isValid(email: visitInfo.userEmail) {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "DexcareSDK Error: userEmail is invalid")
            }
        } else {
            logger?.log("Skipping Email Validation check - customization option is false")
        }

        switch visitInfo.patientDeclaration {
        // If the declaration was "self" then patient is the logged in user and there is no actor
        case .self:
            guard let patientDemographics = dexcarePatient.demographics(from: ehrSystemName) else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Patient is missing demographics in \(ehrSystemName)")
            }

            guard let address = patientDemographics.addresses.first else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Patient is missing an address")
            }

            do {
                try address.validate()
            } catch {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: String(describing: error))
            }

            patient = Patient(
                identifier: dexcarePatient.patientGuid,
                address: address,
                phone: contactPhoneNumber,
                email: visitInfo.userEmail
            )

            actor = nil

        // If the declaration was "other" then the dependent is the patient and the logged in user is the actor
        case .other:

            guard let dependentDemographics = dexcarePatient.demographics(from: ehrSystemName) else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Patient is missing demographics in \(ehrSystemName)")
            }
            guard let dependentAddress = dependentDemographics.addresses.first else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Patient is missing an address")
            }
            guard let actorPatient = actorPatient else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Actor is missing")
            }
            guard let actorDemographics = actorPatient.demographicsLinks.first else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "Actor is missing demographics")
            }
            guard let actorRelationshipToPatient = visitInfo.actorRelationshipToPatient else {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "RetailVisitInformation.actorRelationshipToPatient is not set")
            }

            do {
                try dependentAddress.validate()
            } catch {
                throw ScheduleRetailAppointmentFailedReason.missingInformation(message: String(describing: error))
            }

            patient = Patient(
                identifier: dexcarePatient.patientGuid,
                address: dependentAddress,
                phone: contactPhoneNumber,
                email: visitInfo.userEmail
            )

            actor = Actor(
                patientGuid: nil,
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
            providerId: timeSlot.providerId,
            patientQuestions: visitInfo.patientQuestions
        )

        let modules = ScheduleRetailAppointmentRequest.RegistrationModules(documentSigning: [], billingInfo: billingInfo)

        self.init(
            patient: patient,
            actor: actor,
            visitDetails: visitDetails,
            registrationModules: modules
        )
    }
}
