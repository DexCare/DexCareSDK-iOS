// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// Information needed for scheduling a retail visit other than BillingInformation and RetailTimeSlot
public struct RetailVisitInformation {
    /// The reason for the retail visit.
    public let visitReason: String
    /// Declares whether the patient being treated is the logged in user or another person.
    public let patientDeclaration: PatientDeclaration
    /// This should always be a non-empty email address which can be used to contact the app user.
    /// - Note: the patient email address as returned by Epic is not guaranteed to be present. For this reason, it is recommended to always collect this information from an alternative source, e.g. Auth0 email.
    public let userEmail: String

    /// This should always be a non-empty 10 digit phone number which can be used to contact the app user.
    public let contactPhoneNumber: String

    /// This should always be filled in when booking a Retail Visit for a dependent. When booking for self, this can be nil.
    /// - Note: This is to replace the `PatientDemographic.actorRelationshipToPatient`
    public var actorRelationshipToPatient: RelationshipToPatient?

    /// A generic Question + answer
    public var patientQuestions: [PatientQuestion]?

    public init(
        visitReason: String,
        patientDeclaration: PatientDeclaration,
        userEmail: String,
        contactPhoneNumber: String,
        actorRelationshipToPatient: RelationshipToPatient?,
        patientQuestions: [PatientQuestion]? = nil
    ) {
        self.visitReason = visitReason
        self.patientDeclaration = patientDeclaration
        self.userEmail = userEmail
        self.contactPhoneNumber = contactPhoneNumber
        self.actorRelationshipToPatient = actorRelationshipToPatient
        self.patientQuestions = patientQuestions
    }
}

/// The relationship that a child/other has to their main user account.
///
/// This is required in the `PatientService.createDependentPatient` call when setting up demographics
/// and subsequently calling `RetailService.scheduleRetailAppointment`
public enum RelationshipToPatient: String, Codable, Equatable {
    case mother = "Mother"
    case father = "Father"
    case grandparent = "Grand parent"
    case stepParent = "Step parent"
    case fosterParent = "Foster parent"
    case legalGuardian = "Legal guardian"
    case relative = "Relative"
    case nonRelative = "Non relative"
    case brother = "Brother"
    case sister = "Sister"
    case daughter = "Daughter"
    case son = "Son"
    case friend = "Friend"
    case grandChild = "Grand child"
    case spouse = "Spouse"
    case significantOther = "Significant other"
    case caseManager = "Case manager"
    case domesticPartner = "Domestic partner"
    case employer = "Employer"
    case patientRefused = "Patient refused"
    case powerOfAttorney = "Power of attorney"
    case surrogateOrProxy = "Surrogate or proxy"
}

public typealias ScheduleRetailAppointmentFailure = (ScheduleRetailAppointmentFailedReason) -> Void

/// The main protocol used to call retail visit services
public protocol RetailService {
    /// Returns a list of clinics that are associated with retail visits for the given brand
    /// - Parameters:
    ///    - brand: Brand name of clinics to request
    ///    - success: A closure called with the array of `RetailDepartment` objects
    ///    - failure: A closure called if the request is unsuccessful with a FailedReason describing the error
    func getRetailDepartments(brand: String, success: @escaping ([RetailDepartment]) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Returns a list of clinics that are associated with retail visits for the given brand
    /// - Parameters:
    ///    - departmentName: `RetailDepartment.departmentName` value
    ///    - includeProvider: Flag to get providers associated with a department
    ///    - success: A closure called with `RetailDepartment` object
    ///    - failure: A closure called if the request is unsuccessful with a FailedReason describing the error
    func getRetailDepartment(departmentName: String, includeProvider: Bool, success: @escaping (RetailDepartment) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Returns a `ClinicTimeSlot` object that have information about a particular date range with `TimeSlot`
    /// - Parameters:
    ///    - departmentName: the `Clinic.departmentName` property that was retrieved with `func getRetailDepartments(brand: String, ...)`
    ///    - visitTypeShortName: the optional`VisitTypeShortName` property that was retrieved with `func getRetailDepartments(brand: String, ...). Each `RetailDepartment` has a list of `AllowedVisitType`, which represents visit types the RetailDepartment supports. This parameter will accept any visit type short name as defined on your Epic Instance. If `nil`, SDK will automatically load with `VisitTypeShortName.Illness`.
    ///    - success: The closure called with a `RetailAppointmentTimeSlot` object
    ///    - failure: A closure called if any FailedReason errors are returned
    func getTimeSlots(departmentName: String, visitTypeShortName: VisitTypeShortName?, success: @escaping (RetailAppointmentTimeSlot) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Schedules an appointment for a retail visit.
    ///
    /// When scheduling for the logged-in user, the `actorDexCarePatient` can be nil. When scheduling for a dependent, the `actorDexCarePatient` must be the `DexcarePatient` object of the logged-in user, and the`patientDexCarePatient` must be the dependent. If you do not have a `DexcarePatient` object for the dependent, you can call, `PatientService.findOrCreateDependentPatient` to create one in the system first.
    ///
    /// - Parameters:
    ///    - paymentMethod: An enum with cases for each accepted payment method and associated values for additional
    ///      required information specific to each case.
    ///    - visitInformation: additional information needed for the visit including the reason-for-visit text entered
    ///      by the user and a declaration which describes whether the visit is for the logged in user or another person.
    ///    - timeSlot: The time slot the user has selected from the list returned from call to `timeSlots(clinicURLName:success:failure)`
    ///    - ehrSystemName: The EHR System to where the retail visit is being booked. This is usually grabbed from `Clinic.ehrSystemName`
    ///    - patientDexCarePatient: The `DexcarePatient` object for the patient that the visit is for. When booking for a dependent, this will be the dependent
    ///    - actorDexCarePatient: The `DexcarePatient` object of the actor for when you are booking for a dependent patient. When booking for myself, this can be set to nil.
    ///    - success: The closure called with the Retail Visit Id of the successful retail visit booking.
    ///    - failure: A closure called if any `ScheduleRetailAppointmentFailedReason` errors are returned
    func scheduleRetailAppointment(
        paymentMethod: PaymentMethod,
        visitInformation: RetailVisitInformation,
        timeSlot: TimeSlot,
        ehrSystemName: String,
        patientDexCarePatient: DexcarePatient,
        actorDexCarePatient: DexcarePatient?,
        success: @escaping (String) -> Void,
        failure: @escaping (ScheduleRetailAppointmentFailedReason) -> Void
    )

    // Async Functions
    /// Returns a list of clinics that are associated with retail visits for the given brand
    /// - Parameters:
    ///    - brand: Brand name of clinics to request
    /// - Throws:`FailedReason`
    /// - Returns: An array of `Clinic` objects
    func getRetailDepartments(brand: String) async throws -> [RetailDepartment]

    /// Returns a `ClinicTimeSlot` object that have information about a particular date range with `TimeSlot`
    /// - Parameters:
    ///    - departmentName: the `Clinic.departmentName` property that was retrieved with `func getRetailDepartments(brand: String, ...)`
    ///    - visitTypeShortName: the optional`VisitTypeShortName` property that was retrieved with `func getRetailDepartments(brand: String, ...). Each `Clinic` has a list of `AllowedVisitType`, which represents visit types the RetailDepartment supports. This parameter will accept any visit type short name as defined on your Epic Instance. If `nil`, SDK will automatically load with `VisitTypeShortName.Illness`.
    /// - Throws: `FailedReason`
    /// - Returns: a `ClinicTimeSlot` object
    func getTimeSlots(departmentName: String, visitTypeShortName: VisitTypeShortName?) async throws -> RetailAppointmentTimeSlot

    /// Schedules an appointment for a retail visit.
    ///
    /// When scheduling for the logged-in user, the `actorDexCarePatient` can be nil. When scheduling for a dependent, the `actorDexCarePatient` must be the `DexcarePatient` object of the logged-in user, and the`patientDexCarePatient` must be the dependent. If you do not have a `DexcarePatient` object for the dependent, you can call, `PatientService.findOrCreateDependentPatient` to create one in the system first.
    ///
    /// - Parameters:
    ///    - paymentMethod: An enum with cases for each accepted payment method and associated values for additional
    ///      required information specific to each case.
    ///    - visitInformation: additional information needed for the visit including the reason-for-visit text entered
    ///      by the user and a declaration which describes whether the visit is for the logged in user or another person.
    ///    - timeSlot: The time slot the user has selected from the list returned from call to `timeSlots(clinicURLName:success:failure)`
    ///    - ehrSystemName: The EHR System to where the retail visit is being booked. This is usually grabbed from `Clinic.ehrSystemName`
    ///    - patientDexCarePatient: The `DexcarePatient` object for the patient that the visit is for. When booking for a dependent, this will be the dependent
    ///    - actorDexCarePatient: The `DexcarePatient` object of the actor for when you are booking for a dependent patient. When booking for myself, this can be set to nil.
    /// - Throws: `ScheduleRetailAppointmentFailedReason`
    /// - Returns: The Retail Visit Id of the successful retail visit booking.
    func scheduleRetailAppointment(
        paymentMethod: PaymentMethod,
        visitInformation: RetailVisitInformation,
        timeSlot: TimeSlot,
        ehrSystemName: String,
        patientDexCarePatient: DexcarePatient,
        actorDexCarePatient: DexcarePatient?
    ) async throws -> String

    /// Returns a list of clinics that are associated with retail visits for the given brand
    /// - Parameters:
    ///    - departmentName: `RetailDepartment.departmentName` value
    ///    - includeProvider: Flag to get providers associated with a department
    /// - Throws: `FailedReason`
    /// - Returns: The `RetailDepartment` object found
    func getRetailDepartment(departmentName: String, includeProvider: Bool) async throws -> RetailDepartment
}

protocol InternalRetailService {
    var customizationOptions: CustomizationOptions? { get set }
}

class RetailServiceSDK: RetailService, InternalRetailService {
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

    struct Routes {
        let dexcareRoute: DexcareRoute

        // Schedule
        func scheduleRetailAppointment() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/6/visits/retail")
        }

        // MARK: - Mapping

        func clinics() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v4/departments")
        }

        func clinic(departmentIdentifier: String) -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v4/departments/\(departmentIdentifier)/departmentInfo")
        }

        func timeSlots(clinicURLName: String) -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v2/departments/\(clinicURLName)/timeslots")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.authenticationToken = ""
    }

    // MARK: - Public methods

    func getRetailDepartments(brand: String, success: @escaping ([RetailDepartment]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let clinics = try await getRetailDepartments(brand: brand)
                success(clinics)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getRetailDepartments(brand: String) async throws -> [RetailDepartment] {
        if brand.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "brand must not be empty"))
            throw FailedReason.missingInformation(message: "brand must not be empty")
        }

        let urlRequest = routes.clinics().queryItems([
            "brand": brand,
            "clinicType": "Retail",
        ])

        let requestTask = Task { () -> [RetailDepartment] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get clinics: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(clinics):
            return clinics
        }
    }

    func getTimeSlots(departmentName: String, visitTypeShortName: VisitTypeShortName?, success: @escaping (RetailAppointmentTimeSlot) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let clinicTimeSlot = try await getTimeSlots(departmentName: departmentName, visitTypeShortName: visitTypeShortName)
                success(clinicTimeSlot)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getTimeSlots(departmentName: String, visitTypeShortName: VisitTypeShortName?) async throws -> RetailAppointmentTimeSlot {
        if departmentName.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "departmentName must not be empty"))
            throw FailedReason.missingInformation(message: "departmentName must not be empty")
        }

        let urlRequest = routes.timeSlots(clinicURLName: departmentName).queryItems([
            "visitTypeName": visitTypeShortName?.rawValue ?? "Illness",
        ])

        let requestTask = Task { () -> RetailAppointmentTimeSlot in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get clinic time slots: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["departmentName": departmentName, "visitTypeShortName": visitTypeShortName?.rawValue ?? ""])
            throw FailedReason.from(error: error)
        case let .success(clinicTimeSlot):
            return clinicTimeSlot
        }
    }

    func scheduleRetailAppointment(
        paymentMethod: PaymentMethod,
        visitInformation: RetailVisitInformation,
        timeSlot: TimeSlot,
        ehrSystemName: String,
        patientDexCarePatient: DexcarePatient,
        actorDexCarePatient: DexcarePatient?,
        success: @escaping (String) -> Void,
        failure: @escaping (ScheduleRetailAppointmentFailedReason) -> Void
    ) {
        Task { @MainActor in
            do {
                let visitId = try await scheduleRetailAppointment(
                    paymentMethod: paymentMethod,
                    visitInformation: visitInformation,
                    timeSlot: timeSlot,
                    ehrSystemName: ehrSystemName,
                    patientDexCarePatient: patientDexCarePatient,
                    actorDexCarePatient: actorDexCarePatient
                )
                success(visitId)
            } catch let error as ScheduleRetailAppointmentFailedReason {
                failure(error)
            }
        }
    }

    func scheduleRetailAppointment(paymentMethod: PaymentMethod, visitInformation: RetailVisitInformation, timeSlot: TimeSlot, ehrSystemName: String, patientDexCarePatient: DexcarePatient, actorDexCarePatient: DexcarePatient?) async throws -> String {
        if ehrSystemName.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: ScheduleRetailAppointmentFailedReason.missingInformation(message: "ehrSystemName must not be empty"))
            throw ScheduleRetailAppointmentFailedReason.missingInformation(message: "ehrSystemName must not be empty")
        }

        let request: ScheduleRetailAppointmentRequest!
        do {
            request = try ScheduleRetailAppointmentRequest(
                billingInfo: BillingInformation(paymentMethod: paymentMethod),
                visitInfo: visitInformation,
                timeSlot: timeSlot,
                ehrSystemName: ehrSystemName,
                dexcarePatient: patientDexCarePatient,
                actorPatient: actorDexCarePatient,
                customization: customizationOptions,
                logger: dexcareConfiguration.logger
            )

        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["patientGuid": patientDexCarePatient.patientGuid])
            throw (error as? ScheduleRetailAppointmentFailedReason ?? ScheduleRetailAppointmentFailedReason.from(error: error))
        }

        let urlRequest = routes.scheduleRetailAppointment().body(json: request).token(authenticationToken)

        let requestTask = Task { () -> ScheduleRetailAppointmentResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get schedule retail visit: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["patientGuid": patientDexCarePatient.patientGuid])
            throw ScheduleRetailAppointmentFailedReason.from(error: error)
        case let .success(appointmentResponse):
            return appointmentResponse.visitId
        }
    }

    func getRetailDepartment(departmentName: String, includeProvider: Bool = false, success: @escaping (RetailDepartment) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let clinic = try await getRetailDepartment(departmentName: departmentName, includeProvider: includeProvider)
                success(clinic)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getRetailDepartment(departmentName: String, includeProvider: Bool = false) async throws -> RetailDepartment {
        if departmentName.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "departmentName must not be empty"))
            throw FailedReason.missingInformation(message: "departmentName must not be empty")
        }

        let urlRequest = routes.clinic(departmentIdentifier: departmentName).queryItems([
            "withProviders": includeProvider ? "true" : "false"
        ])

        let requestTask = Task { () -> RetailDepartment in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Could not get clinic - \(departmentName): \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(clinic):
            return clinic
        }
    }
}
