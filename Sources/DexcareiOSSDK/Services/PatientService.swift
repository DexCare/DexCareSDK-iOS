// Copyright © 2020 DexCare. All rights reserved.
import Foundation

// sourcery: AutoMockable, ProtocolPromiseExtension
/// Base Protocol used to create patients, get patients
public protocol PatientService {
    /// Returns the DexcarePatient that is available after setting the Authentication Token
    ///
    /// - Parameters:
    ///    - success: The closure called with the DexcarePatient in the system
    ///    - failure: A closure called if any FailedReason errors are returned
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func getPatient(success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Returns the DexcarePatient from EMR that is available after setting the Authentication Token
    ///
    /// - Parameters:
    ///    - success: The closure called with the DexcarePatient in the system
    ///    - failure: A closure called if any FailedReason errors are returned
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken from MyChart
    func getEMRPatient(success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Creates a Dexcare patient.
    ///
    /// The SDK will return the patient found in the requested EHR system. If no patient with the same patientGuid is found, the system will attempt to find a matching patient by fuzzy matching with the patient demographics passed in, link that EHR patient record with the DexcarePatient and return it. If no patient record can be found in the EHR system, a new one is created, linked to the DexcarePatient and returned.
    /// - Parameters:
    ///   - ehrSystem: The Ehr System name that will be used in creating the patient
    ///   - patientDemographics: Patient Demographic information used to create the patient. Note: PatientDemographics.ehrSystemName will use `ehrSystem` that is passed in to override any existing EHRSystem already in demographics
    ///   - success: The closure called with the DexcarePatient in the system
    ///   - failure: A closure called if any FailedReason errors are returned
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func findOrCreatePatient(inEhrSystem: String, patientDemographics: PatientDemographics, success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Creates a Dexcare dependent patient.
    ///
    /// This api will find or create a DexCare patient record for the patient, without linking it to the current authorized account.
    /// - Parameters:
    ///   - ehrSystem: The Ehr System name that will be used in creating the patient
    ///   - dependentPatientDemographics: Dependent Patient Demographic information used to create the dependent patient. Note: PatientDemographics.ehrSystemName will use `ehrSystem` that is passed in to override any existing EHRSystem already in demographics
    ///   - success: The closure called with the DexcarePatient in the system
    ///   - failure: A closure called if any FailedReason errors are returned
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func findOrCreateDependentPatient(inEhrSystem: String, dependentPatientDemographics: PatientDemographics, success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void)

    /// Loads a list of suffixes from the server
    ///
    /// These can be used in a drop down for demographics. Changes to this list can be changed on the server only.
    /// - Parameters:
    ///   - success: The closure called with an array of Strings of suffixes. ie ["Dr", "Jr.", "III"]
    ///   - failure: A closure called if any FailedReason errors are returned
    func getSuffixes(success: @escaping (([String]) -> Void), failure: @escaping ((FailedReason) -> Void))

    /// Sends a request to delete the Patient Account at DexCare
    /// This does not delete any epic or other accounts. The request may not be instant and may take some time to fully delete.
    /// - Parameters:
    ///   - success: The closure called when successfully returned
    ///   - failure: A closure called if any FailedReason errors are returned
    func deletePatientAccount(success: @escaping (() -> Void), failure: @escaping ((FailedReason) -> Void))

    // Async
    // sourcery: StubName=getPatientAsync, SkipPromiseExtension
    /// Returns the DexcarePatient that is available after setting the Authentication Token
    /// - Throws:`FailedReason`
    /// - Returns: The `DexcarePatient` in the system
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func getPatient() async throws -> DexcarePatient

    // sourcery: StubName=getEMRPatientAsync, SkipPromiseExtension
    /// Returns the DexcarePatient from EMR that is available after setting the Authentication Token
    /// - Throws:`FailedReason`
    /// - Returns: The `DexcarePatient` in the system
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken from MyChart
    func getEMRPatient() async throws -> DexcarePatient

    // sourcery: StubName=findOrCreatePatientAsync, SkipPromiseExtension
    /// The SDK will return the patient found in the requested EHR system. If no patient with the same patientGuid is found, the system will attempt to find a matching patient by fuzzy matching with the patient demographics passed in, link that EHR patient record with the DexcarePatient and return it. If no patient record can be found in the EHR system, a new one is created, linked to the DexcarePatient and returned.
    /// - Parameters:
    ///   - ehrSystem: The Ehr System name that will be used in creating the patient
    ///   - patientDemographics: Patient Demographic information used to create the patient. Note: PatientDemographics.ehrSystemName will use `ehrSystem` that is passed in to override any existing EHRSystem already in demographics
    /// - Throws:`FailedReason`
    /// - Returns:The `DexcarePatient` in the system
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func findOrCreatePatient(inEhrSystem: String, patientDemographics: PatientDemographics) async throws -> DexcarePatient

    // sourcery: StubName=findOrCreateDependentPatientAsync, SkipPromiseExtension
    /// Creates a Dexcare dependent patient.
    ///
    /// This api will find or create a DexCare patient record for the patient, without linking it to the current authorized account.
    /// - Parameters:
    ///   - ehrSystem: The Ehr System name that will be used in creating the patient
    ///   - dependentPatientDemographics: Dependent Patient Demographic information used to create the dependent patient. Note: PatientDemographics.ehrSystemName will use `ehrSystem` that is passed in to override any existing EHRSystem already in demographics
    /// - Throws: `FailedReason`
    /// - Returns: The `DexcarePatient` in the system
    /// - Precondition: `dexcareSDK.authentication.signIn()` must be set with a valid accessToken
    func findOrCreateDependentPatient(inEhrSystem: String, dependentPatientDemographics: PatientDemographics) async throws -> DexcarePatient

    // sourcery: StubName=getSuffixesAsync, SkipPromiseExtension
    /// Loads a list of suffixes from the server
    ///
    /// These can be used in a drop down for demographics. Changes to this list can be changed on the server only.
    /// - Throws:`FailedReason`
    /// - Returns:An array of Strings of suffixes. ie ["Dr", "Jr.", "III"]
    func getSuffixes() async throws -> [String]

    // sourcery: StubName=deletePatientAccountAsync, SkipPromiseExtension
    /// Sends a request to delete the Patient Account at DexCare
    /// This does not delete any epic or other accounts. The request may not be instant and may take some time to fully delete.
    /// - Throws: `FailedReason`
    /// - Returns: If returns, successfully started the deletion process
    func deletePatientAccount() async throws
}

class PatientServiceSDK: PatientService {
    // a helper property for tests so we can override the token
    var authenticationToken: String {
        get {
            return self.asyncNetworkService.authenticationToken
        }
        set {
            self.asyncNetworkService.authenticationToken = newValue
        }
    }

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

        func getPatient() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v1/patient")
        }

        func getEMRPatient() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v1/emr/patient/getByToken")
        }

        func createPatient() -> URLRequest {
            return dexcareRoute.fhirBuilder.post("/v1/patient/self")
        }

        func createDependentPatient() -> URLRequest {
            return dexcareRoute.fhirBuilder.post("/v1/patient/other")
        }

        func deletePatient() -> URLRequest {
            return dexcareRoute.fhirBuilder.delete("v1/patient/deletePatientAccount")
        }

        func getSuffixes() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("/v1/suffixes")
        }
    }

    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)

        self.authenticationToken = ""
    }

    // MARK: - Public methods

    func getPatient(success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let patient = try await getPatient()
                success(patient)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getEMRPatient(success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let patient = try await getEMRPatient()
                success(patient)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getPatient() async throws -> DexcarePatient {
        let patientRequest = routes.getPatient().token(authenticationToken)

        let requestTask = Task { () -> DexcarePatient in
            return try await asyncNetworkService.requestObject(patientRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            dexcareConfiguration.logger?.log("Could not load patient: \(error.localizedDescription)")
            throw FailedReason.from(error: error)
        case let .success(patient):
            return patient
        }
    }

    func getEMRPatient() async throws -> DexcarePatient {
        let patientRequest = routes.getEMRPatient().token(authenticationToken)
        do {
            return try await asyncNetworkService.requestObject(patientRequest)
        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            dexcareConfiguration.logger?.log("Could not load EMR patient: \(error.localizedDescription)")
            throw FailedReason.from(error: error)
        }
    }

    func findOrCreatePatient(inEhrSystem ehrSystem: String, patientDemographics: PatientDemographics, success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let patient = try await findOrCreatePatient(inEhrSystem: ehrSystem, patientDemographics: patientDemographics)
                success(patient)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func findOrCreatePatient(inEhrSystem ehrSystem: String, patientDemographics: PatientDemographics) async throws -> DexcarePatient {
        if ehrSystem.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "ehrSystem must not be empty"))
            throw FailedReason.missingInformation(message: "ehrSystem must not be empty")
        }

        // validate demographics
        do {
            try patientDemographics.validate()
        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        }

        // update the ehrSystem that is passed in.
        var updatedDemographics = patientDemographics
        updatedDemographics.ehrSystemName = ehrSystem

        let urlRequest = routes.createPatient().body(json: updatedDemographics).token(authenticationToken)
        let requestTask = Task { () -> PatientGuid in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Error creating patient: \(error)", level: .error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case .success:
            // call getPatient to get latest info as createPatient just returns patientGuid
            return try await getPatient()
        }
    }

    func findOrCreateDependentPatient(inEhrSystem ehrSystem: String, dependentPatientDemographics: PatientDemographics, success: @escaping (DexcarePatient) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let patient = try await findOrCreateDependentPatient(inEhrSystem: ehrSystem, dependentPatientDemographics: dependentPatientDemographics)
                success(patient)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func findOrCreateDependentPatient(inEhrSystem ehrSystem: String, dependentPatientDemographics: PatientDemographics) async throws -> DexcarePatient {
        if ehrSystem.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "ehrSystem must not be empty"))
            throw FailedReason.missingInformation(message: "ehrSystem must not be empty")
        }

        // validate demographics
        do {
            try dependentPatientDemographics.validate()
        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        }

        // update the ehrSystem that is passed in.
        var updatedDemographics = dependentPatientDemographics
        updatedDemographics.ehrSystemName = ehrSystem

        let urlRequest = routes.createDependentPatient().body(json: updatedDemographics).token(authenticationToken)

        let requestTask = Task { () -> PatientGuid in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Error creating dependent patient: \(error)", level: .error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(patientGuid):
            // We have to manually create the dexcarePatient as we can't get Patient on a dependent
            let dependentPatient = DexcarePatient(
                patientGuid: patientGuid.patientGuid,
                demographicsLinks: [updatedDemographics]
            )
            return dependentPatient
        }
    }

    func getSuffixes(success: @escaping (([String]) -> Void), failure: @escaping ((FailedReason) -> Void)) {
        Task { @MainActor in
            do {
                let suffixes = try await getSuffixes()
                success(suffixes)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func getSuffixes() async throws -> [String] {
        let urlRequest = routes.getSuffixes()
        let requestTask = Task { () -> [String] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Error getting suffixes: \(error)", level: .error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case let .success(suffixes):
            return suffixes
        }
    }

    func deletePatientAccount(success: @escaping (() -> Void), failure: @escaping ((FailedReason) -> Void)) {
        Task { @MainActor in
            do {
                try await deletePatientAccount()
                success()
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }

    func deletePatientAccount() async throws {
        let urlRequest = routes.deletePatient().token(authenticationToken)

        let requestTask = Task { () -> String in
            return try await asyncNetworkService.requestString(urlRequest)
        }
        let result = await requestTask.result

        switch result {
        case let .failure(error):
            dexcareConfiguration.logger?.log("Error deleting patient account: \(error)", level: .error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw FailedReason.from(error: error)
        case .success:
            return
        }
    }
}
