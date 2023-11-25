// Copyright © 2019 Providence. All rights reserved.

import Foundation
import UIKit

public typealias VisitCompletion = (VisitCompletionReason) -> Void

typealias BookingSuccess = (String) -> Void
typealias ResumeSuccess = () -> Void
typealias VisitFailure = (VirtualVisitFailedReason) -> Void

/// A dictionary of custom additional details that can be added to a visit.
public typealias AdditionalDetails = [String: String]

/// Base Protocol to create, setup, cancel Virtual Visits
public protocol VirtualService {

    /// Resumes a Virtual Visit
    /// - Parameters:
    ///   - visitId: An existing VisitId that is active
    ///   - presentingViewController: A ViewController from which the DexcareSDK will present the waiting room view and eventually the virtual meeting
    ///   - dexCarePatient: The DexcarePatient for this visit, loaded from a previous `patientService.getPatient()` call. This patient's display name will be used during the visit.
    ///   - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a paramter.
    ///   - success: A closure called when a visit is successfully resumed.
    ///   - failure: A closure called if any VirtualVisitFailedReason errors are returned
    /// - Precondition: Must call `patientService.getPatient()` before calling this method
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, dexCarePatient: DexcarePatient, onCompletion: @escaping VisitCompletion, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)
    
    /// Resumes a Virtual Visit
    /// - Parameters:
    ///   - visitId: An existing VisitId that is active
    ///   - presentingViewController: A ViewController from which the DexcareSDK will present the waiting room view and eventually the virtual meeting
    ///   - ehrPatient: The EhrPatient for this visit. This patient's display name will be used during the visit.
    ///   - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a paramter.
    ///   - success: A closure called when a visit is successfully resumed.
    ///   - failure: A closure called if any VirtualVisitFailedReason errors are returned
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, ehrPatient: EhrPatient, onCompletion: @escaping VisitCompletion, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)
    
    /// Updates a push notification device token
    /// - Parameters:
    ///   - token: a device token that is returned by an iOS device in AppDelegate.application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    func updatePushNotificationDeviceToken(token: Data)
         
    /// Submit the patient feedback questions and answers for a virtual visit.
    ///
    /// - Parameter feedbacks: An array of `VirtualFeedback` enums, each representing a single feedback question and answer asked to the patient.
    /// - Parameter success: closure when the feedback has been posted successfully
    /// - Parameter failure: closure when the feedback posting failed
    /// - Precondition: Must call `visitService.startVirtualVisit` or `visitService.resumeVirtualVisit` before calling this method
    func postFeedback(feedbacks: [VirtualFeedback], success: @escaping () -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Cancels an existing valid virtual visit.
    /// - Parameters:
    ///   - visitId:The visitId that you wish to cancel
    ///   - success: closure when the visit was successfully cancelled
    ///   - failure: closure when the cancel visit fails. If `VirtualVisitFailedReason.virtualVisitNotFound` is returned it means the visit no longer exists.
    func cancelVirtualVisit(visitId: String, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)
        
    /// Sets the delegate to invoke various events allowing you to capture analytics.
    /// - Note: See `VirtualEventDelegate` for more information
    func setVirtualEventDelegate(delegate: VirtualEventDelegate?)
    
    /// Fetches the estimated `WaitTime` for a virtual visit
    /// - Important: `WaitTime` is estimated and may change. The time returned should not be used as a definitive time when a Virtual Visit will begin.
    /// - Parameters:
    ///   - visitId: A `id` from a start or a resume virtual visit.
    ///   - success: A closure called with a `WaitTime` return value
    ///   - failure: A closure called if any `WaitTimeFailedReason` errors are returned
    func getEstimatedWaitTime(visitId: String, success: @escaping (WaitTime) -> Void, failure: @escaping (WaitTimeFailedReason) -> Void)
    
    /// Gets the statistics report from the OpenTok (Vonage) SDK from a virtual visit.
    /// Virtual Visit must have been started in the current app session, and the Provider must have started the visit for this method to return any results.
    /// These statistics are only stored in memory, and are cleared upon starting a new visit, calling DexCareSDK.signOut(), or by closing the app (since they're only in memory)
    /// - Note: See `VideoCallStatistics` for more information on values returned
    /// - Returns: An optional`VideoCallStatistics` object containing stats about the visit
    func getVideoCallStatistics() -> VideoCallStatistics?
    
    /// Fetches the latest status for a virtual visit
    ///
    /// - Parameters:
    ///   - visitId: A `id` from a start or a resume virtual visit.
    ///   - success: A closure called with a `VisitStatus` enum return value
    ///   - failure: A closure called if any `FailedReason` errors are returned
    func getVirtualVisitStatus(visitId: String, success: @escaping (VisitStatus) -> Void, failure: @escaping (FailedReason) -> Void)
        
    /// Fetches the WaitTimes and Availabilities
    ///
    /// If no extra parameters are passed in to filter on, all `WaitTimeAvailability` are returned, including any that are currently not available.
    /// - Parameters:
    ///   - regionCodes: An optional array of RegionCodes to filter the results on
    ///   - assignmentQualifiers: An optional array of `VirtualVisitAssignmentQualifier` to filter the results on
    ///   - visitTypeNames: An optional array of `VirtualVisitType` representing VisitTypeNames to filter the results on
    ///   - practiceId: A `VirtualPractice.practiceId` to filter the results on
    ///   - homeMarket: A string to filter the results for a homeMarket
    ///   - success: A closure called with a `WaitTimeAvailability` array return value
    ///   - failure: A closure called if any `FailedReason` errors are returned
    func getWaitTimeAvailability(regionCodes: [String]?, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?, success: @escaping ([WaitTimeAvailability]) -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Fetches the supported `VirtualVisitAssignmentQualifier` objects that can be used to schedule a virtual visit and filter `WaitTimeAvailability`.
    ///
    /// - Parameters:
    ///   - success: A closure called with a `VirtualVisitAssignmentQualifier` array return value
    ///   - failure: A closure called if any `FailedReason` errors are returned
    func getAssignmentQualifiers(success: @escaping ([VirtualVisitAssignmentQualifier]) -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Fetches the supported `VirtualVisitModality` objects
    ///
    /// - Parameters:
    ///   - success: A closure called with a `VirtualVisitModality` array return value
    ///   - failure: A closure called if any `FailedReason` errors are returned
    func getModalities(success: @escaping ([VirtualVisitModality]) -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Starts or creates a virtual visit with a `DexcarePatient`
    ///
    /// Call this method to create a new virtual visit and show its full-screen user interface on the specified view controller.
    /// Before calling this method, at least one patient must be created by calling patientService.findOrCreatePatient() if the current user is the patient, patientService.findOrCreateDependentPatient() if the patient is a dependent (anyone other than the logged in user) must call.
    ///
    /// If the patient already exists, you do not need to call the above method, but the demographic must exist in the ehrSystem you are trying to book to.
    ///
    /// - Parameters:
    ///    - presentingViewController: A view controller from which the virtual visit UI (waiting room, video call screen, feedback) will be presented.
    ///    - dexcarePatient: a `DexcarePatient` object used to book the virtual visit under. When booking for a dependent, this will be the dependent patient
    ///    - virtualVisitDetails: A struct containing details specific to this visit request
    ///    - paymentMethod: An enumeration with payment/billing information for this visit
    ///    - actor: a `DexcarePatient` object when booking a virtual visit for a dependent. A `relationshipToPatient` must be set on the virtualVisitDetails property in order to book.
    ///    - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a parameter.
    ///    - success: A closure called when a visit is successfully created. The new visitId is passed back as the only parameter.
    ///    - failure: A closure called if any FailedReason errors are returned
    /// - Important: If you pass up `VirtualVisitDetails.visitTypeName` of `.phone` the `onCompletion` closure will be called with a `VisitCompletionReason.phoneVisit`. This does not mean the visit is complete, but that you have successfully scheduled a visit and the provider will phone you. The full screen user interface will not show on a phone visit.
    func createVirtualVisit(presentingViewController: UIViewController, dexcarePatient: DexcarePatient, virtualVisitDetails: VirtualVisitDetails, paymentMethod: PaymentMethod, actor: DexcarePatient?, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)
    
    /// Starts or creates a virtual visit with an `EhrPatient`
    ///
    /// Call this method to create a new virtual visit and show its full-screen user interface on the specified view controller.
    ///
    /// - Parameters:
    ///    - presentingViewController: A view controller from which the virtual visit UI (waiting room, video call screen, feedback) will be presented.
    ///    - ehrPatient: an `EhrPatient` object used to book the virtual visit under. When booking for a dependent, this will be the dependent patient
    ///    - virtualVisitDetails: A struct containing details specific to this visit request
    ///    - paymentMethod: An enumeration with payment/billing information for this visit
    ///    - actor: a `EhrPatient` object when booking a virtual visit for a dependent. A `relationshipToPatient` must be set on the virtualVisitDetails property in order to book.
    ///    - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a parameter.
    ///    - success: A closure called when a visit is successfully created. The new visitId is passed back as the only parameter.
    ///    - failure: A closure called if any FailedReason errors are returned
    /// - Important: If you pass up `VirtualVisitDetails.visitTypeName` of `.phone` the `onCompletion` closure will be called with a `VisitCompletionReason.phoneVisit`. This does not mean the visit is complete, but that you have successfully scheduled a visit and the provider will phone you. The full screen user interface will not show on a phone visit.
    func createVirtualVisit(presentingViewController: UIViewController, ehrPatient: EhrPatient, virtualVisitDetails: VirtualVisitDetails, paymentMethod: PaymentMethod, actor: EhrPatient?, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)
    
    // MARK: ASYNC FUNCTIONS
    /// Submit the patient feedback questions and answers for a virtual visit.
    ///
    /// - Parameters:
    /// - feedbacks: An array of `VirtualFeedback` enums, each representing a single feedback question and answer asked to the patient.
    /// - Throws:`FailedReason`
    /// - Returns:When the feedback has been posted successfully
    /// - Precondition: Must call `visitService.startVirtualVisit` or `visitService.resumeVirtualVisit` before calling this method
    func postFeedback(feedbacks: [VirtualFeedback]) async throws
    
    /// Cancels an existing valid virtual visit.
    /// - Parameters:
    ///   - visitId:The visitId that you wish to cancel
    /// - Throws:When the cancel visit fails. If `VirtualVisitFailedReason.virtualVisitNotFound` is returned it means the visit no longer exists.
    /// - Returns:When successfully cancelled
    func cancelVirtualVisit(visitId: String) async throws
    
    /// Fetches the estimated `WaitTime` for a virtual visit
    /// - Important: `WaitTime` is estimated and may change. The time returned should not be used as a definitive time when a Virtual Visit will begin.
    /// - Parameters:
    ///   - visitId: A `id` from a start or a resume virtual visit.
    /// - Throws:`WaitTimeFailedReason`
    /// - Returns: `WaitTime` object
    func getEstimatedWaitTime(visitId: String) async throws -> WaitTime
    
    /// Fetches the supported `VirtualVisitAssignmentQualifier` objects that can be used to schedule a virtual visit and filter `WaitTimeAvailability`.
    /// - Throws:`FailedReason`
    /// - Returns:: A `VirtualVisitAssignmentQualifier` array
    func getAssignmentQualifiers() async throws -> [VirtualVisitAssignmentQualifier]
    
    /// Fetches the supported `VirtualVisitModality` objects
    /// - Throws:`FailedReason`
    /// - Returns:`VirtualVisitModality` array
    func getModalities() async throws -> [VirtualVisitModality]
    
    /// Resumes a Virtual Visit
    /// - Parameters:
    ///   - visitId: An existing VisitId that is active
    ///   - presentingViewController: A ViewController from which the DexcareSDK will present the waiting room view and eventually the virtual meeting
    ///   - dexCarePatient: The DexcarePatient for this visit, loaded from a previous `patientService.getPatient()` call. This patient's display name will be used during the visit.
    ///   - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a parameter.
    /// - Throws: `VirtualVisitFailedReason`
    /// - Returns: When a visit is successfully resumed
    /// - Precondition: Must call `patientService.getPatient()` before calling this method
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, dexCarePatient: DexcarePatient, onCompletion: @escaping VisitCompletion) async throws
    
    /// Resumes a Virtual Visit
    /// - Parameters:
    ///   - visitId: An existing VisitId that is active
    ///   - presentingViewController: A ViewController from which the DexcareSDK will present the waiting room view and eventually the virtual meeting
    ///   - ehrPatient: The EhrPatient for this visit. This patient's display name will be used during the visit.
    ///   - onCompletion: A closure called when a visit has been completed successfully or has ended with an error. A VisitCompletionReason is passed in as a parameter.
    /// - Throws: `VirtualVisitFailedReason`
    /// - Returns: When a visit is successfully resumed
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, ehrPatient: EhrPatient, onCompletion: @escaping VisitCompletion) async throws
    
    /// Fetches the WaitTimes and Availabilities
    ///
    /// If no extra parameters are passed in to filter on, all `WaitTimeAvailability` are returned, including any that are currently not available.
    /// - Parameters:
    ///   - regionCodes: An optional array of RegionCodes to filter the results on
    ///   - assignmentQualifiers: An optional array of `VirtualVisitAssignmentQualifier` to filter the results on
    ///   - visitTypeNames: An optional array of `VirtualVisitType` representing VisitTypeNames to filter the results on
    ///   - practiceId: A `VirtualPractice.practiceId` to filter the results on
    ///   - homeMarket: A string to filter the results for a homeMarket
    /// - Throws: `FailedReason`
    /// - Returns: `WaitTimeAvailability` array
    func getWaitTimeAvailability(regionCodes: [String]?, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?) async throws -> [WaitTimeAvailability]
    
    /// Fetches the latest status for a virtual visit
    ///
    /// - Parameters:
    ///   - visitId: A `id` from a start or a resume virtual visit.
    /// - Throws: `FailedReason`
    /// - Returns:`VisitStatus` enum
    func getVirtualVisitStatus(visitId: String) async throws -> VisitStatus
    
}

protocol InternalVirtualService: AnyObject {
    
    var virtualEventDelegate: VirtualEventDelegate? { get set }
    var virtualVisitManager: VirtualVisitManagerType? { get set }
    
    var currentVirtualVisitId: String? { get set }
    var currentVirtualPatientId: String? { get set }
    var currentVirtualStartTime: Date? { get set }
    var currentVirtualEndTime: Date? { get set }

    var customizationOptions: CustomizationOptions? { get set }
    
    func sendWaitingRoomEvents(visitId: String, permissions: Permissions?)
    
    func getEstimatedWaitTime(visitId: String) async throws -> WaitTime
    
    func postChatMessage(visitId: String, sessionId: String, message: SignalInstantMessage) async throws
    
    func onVisitSuccess(visitId: String)
    func onVisitFailure(reason: VirtualVisitFailedReason)
    
    // Integrations: Tytocare
    
    /// Pairs a device. String returned will be used in the QR Code generation.
    func pairDevice(visitId: String) async throws -> String
    
    // Async
    func cancelVirtualVisit(visitId: String) async throws
    
}

public enum VisitCompletionReason: String {
    /// Virtual visit was successfully completed
    case completed
    /// User canceled the virtual visit
    case canceled
    /// Trying to join after you are already in the conference
    case alreadyInConference
    /// Trying to join after the conference is already full
    case conferenceFull
    /// Trying to join an inactive conference
    case conferenceInactive
    /// Trying to join a conference that doesn't exist
    case conferenceNonExistent
    /// The microphone and camera is not connected
    case micAndCamNotConnected
    /// Encountered network issues
    case networkIssues
    /// Disconnected and exceeded reconnection attempts
    case exceededReconnectAttempt
    /// Participant has already join the conference somewhere else
    case joinedElsewhere
    /// Staff Declined the Visit
    case staffDeclined
    /// Virtual visit failed with an unknown error
    case failed
    /// Phone Visit has been requested.
    case phoneVisit
}

class VirtualServiceSDK: VirtualService, InternalVirtualService {
   
    weak var virtualEventDelegate: VirtualEventDelegate?
    
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
    
    var dexcareConfiguration: DexcareConfiguration
    let routes: Routes
    var asyncNetworkService: AsyncNetworkService

    lazy var permissionService: DevicePermissionService = DevicePermissionRequester()
    lazy var tokenPersister: PersistsDeviceToken = TokenPersister()
    lazy var tokenRegister: RemoteNotificationAppRegistering = UIApplication.shared
    
    var visitSuccess: BookingSuccess?
    var resumeSuccess: ResumeSuccess?
    var visitFailure: VisitFailure?
    
    var virtualVisitManager: VirtualVisitManagerType? {
        didSet {
            if virtualVisitManager == nil {
                cleanupNotificationDeviceToken()
            }
        }
    }
    
    var currentVirtualVisitId: String?
    var currentVirtualPatientId: String?
    var currentVirtualStartTime: Date?
    var currentVirtualEndTime: Date?
    
    var deviceToken: String = ""
    
    var customizationOptions: CustomizationOptions?
    
    struct Routes {
        // MARK: - Regions
        let dexcareRoute: DexcareRoute

        // MARK: - Schedule
        func scheduleV9() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/9/visits")
        }
        
        // MARK: - Resume
        
        func resume(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/visits/\(visitId)/summary")
        }
        
        // MARK: - OpenTok
        
        func token(visitId: String, sessionId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/6/visit/\(visitId)/token/\(sessionId)")
        }
        
        func chat(visitId: String, sessionId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/6/visit/\(visitId)/chat/\(sessionId)")
        }
        
        // MARK: - In Visit
        
        func cancel(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/9/visits/virtual/\(visitId)/cancel")
        }
        
        func waitTime(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("api/9/visits/\(visitId)/waittime")
        }
        
        // MARK: - Push Notification
        
        func deviceNotificationRegister(appId: String, platform: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/6/mobile/app/\(appId)/platform/\(platform)/devices")
        }
        
        func deviceNotificationUnregister(token: String, appId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.delete("/api/6/mobile/app/\(appId)/device/\(token)")
        }
        
        // MARK: - Feedback
        
        func feedback(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/6/visit/\(visitId)/feedback")
        }
        
        // MARK: Tytocare PairDevice
        func pairDevice(visitId: String, accountKey: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("api/8/visits/\(visitId)/integrations/\(accountKey)/devices")
        }
        
        // MARK: TechCheck
        func waitingRoomEvents(visitId: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.post("/api/8/visits/virtual/\(visitId)/waitingRoomEvents")
        }
        
        // MARK: WaitTime
        func getWaitTimeAvailability() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/regions/waittimes")
        }
        
        func getAssignmentQualifiers() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/assignmentqualifiers")
        }
        
        func getModalities() -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/9/modalities")
        }
    }
    
    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.customizationOptions = CustomizationOptions(tytoCareConfig: TytoCareConfig(helpURL: nil), virtualConfig: nil, validateEmails: true)
        self.authenticationToken = ""
        
        // Clear any token that was saved from an unfinished virtual visit
        cleanupNotificationDeviceToken()
    }
    
    // MARK: - Public methods
    
    // v9
    func createVirtualVisit(presentingViewController: UIViewController, dexcarePatient: DexcarePatient, virtualVisitDetails: VirtualVisitDetails, paymentMethod: PaymentMethod, actor: DexcarePatient?, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) {
        
        guard let demographics = dexcarePatient.demographicsLinks.first else {
            failure(.missingInformation(message: "No patient demographics found"))
            return
        }
        
        var virtualPatient: EhrPatient!
        do {
            virtualPatient = try DexcarePatient.createDexcareVirtualPatient(patientGuid: dexcarePatient.patientGuid, patientDemographics: demographics)
        } catch {
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["PatientGuid": dexcarePatient.patientGuid])
            if let message = error as? String {
                failure(.missingInformation(message: message))
            } else {
                failure(.incompleteRequestData)
            }
            return
        }
        
        var virtualActor: EhrPatient?
        if let actor = actor {
            guard let demographics = actor.demographicsLinks.first else {
                failure(.missingInformation(message: "No actor demographics found"))
                return
            }
            do {
                virtualActor = try DexcarePatient.createDexcareVirtualPatient(patientGuid: actor.patientGuid, patientDemographics: demographics, relationshipToPatient: virtualVisitDetails.actorRelationshipToPatient)
            } catch {
                self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["PatientGuid": actor.patientGuid])
                if let message = error as? String {
                    failure(.missingInformation(message: message))
                } else {
                    failure(.incompleteRequestData)
                }
                return
            }
        }
        
        let request: V9VirtualVisitRequest!
        do {
            request = try V9VirtualVisitRequest(
                billingInformation: BillingInformation(paymentMethod: paymentMethod),
                virtualVisitDetails: virtualVisitDetails,
                patient: virtualPatient,
                actor: virtualActor,
                customization: customizationOptions
            )
        } catch {
            dexcareConfiguration.logger?.log("Error creating virtual visit: \(error)", level: .error)
            
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["PatientGuid": dexcarePatient.patientGuid])
            if let message = error as? String {
                failure(.missingInformation(message: message))
            } else {
                failure(.incompleteRequestData)
            }
            return
        }
        
        Task { @MainActor in
            do {
                try await scheduleV9VirtualVisit(presentingViewController: presentingViewController, request: request, onCompletion: onCompletion, success: success, failure: failure)
            } catch let error as VirtualVisitFailedReason {
                failure(error)
            }
        }
      
    }
    
    func createVirtualVisit(presentingViewController: UIViewController, ehrPatient: EhrPatient, virtualVisitDetails: VirtualVisitDetails, paymentMethod: PaymentMethod, actor: EhrPatient?, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) {
        
        var virtualActor: EhrPatient? = actor
        virtualActor?.relationshipToPatient = virtualVisitDetails.actorRelationshipToPatient
        
        let request: V9VirtualVisitRequest!
        do {
            request = try V9VirtualVisitRequest(
                billingInformation: BillingInformation(paymentMethod: paymentMethod),
                virtualVisitDetails: virtualVisitDetails,
                patient: ehrPatient,
                actor: virtualActor,
                customization: customizationOptions
            )
        } catch {
            dexcareConfiguration.logger?.log("Error creating virtual visit: \(error)", level: .error)
            
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ehrPatient.identifiers)
            if let message = error as? String {
                failure(.missingInformation(message: message))
            } else {
                failure(.incompleteRequestData)
            }
            return
        }
        
        Task { @MainActor in
            do {
                try await scheduleV9VirtualVisit(presentingViewController: presentingViewController, request: request, onCompletion: onCompletion, success: success, failure: failure)
            } catch let error as VirtualVisitFailedReason {
                failure(error)
            }
        }
        
    }
    
    internal func scheduleV9VirtualVisit(presentingViewController: UIViewController, request: V9VirtualVisitRequest, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) async throws {
        
        let displayName = request.patient.displayName
        
        self.visitSuccess = success
        self.visitFailure = failure
        
        let virtualVisitType = request.visitDetails.visitTypeName
        let permissions = await permissionService.requestPermissions(withVisitType: virtualVisitType)
        
        // phone visit types don't need any permissions - above will ask for notifications if they want
        if virtualVisitType == .virtual {
            guard permissions.granted else {
                throw VirtualVisitFailedReason.permissionDenied(type: permissions.deniedPermissionType)
            }
        }
        
        do {
            let scheduleVisitResponse = try await scheduleV9VirtualVisit(request: request)
            guard let visitId = scheduleVisitResponse.visitId else {
                assertionFailure("successful scheduling response must have a visitId")
                throw VirtualVisitFailedReason.missingInformation(message: "no visit id after scheduled virtual visit.")
            }
            
            let response = try await fetchExistingVirtualVisit(visitId: visitId)
            
            let (_, modality) = try await startVisitWithResumeVisitResponse(
                response,
                presentingViewController: presentingViewController,
                displayName: displayName,
                onCompletion: onCompletion
            )
            
            // We don't do anything here, as the success gets returned later inside of Tokbox inside the `visitSuccess` property
            // Even though the server returned a visitId, Tokbox needs to initialize and do it's thing before we deem it a valid successfully start
            if modality != .virtual {
                success(visitId)
            }
            
        } catch {
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: VirtualVisitFailedReason.from(error: error), data: request.patient.identifiers)
            failure(VirtualVisitFailedReason.from(error: error))
            self.cleanupVisitClosures()
        }
    }
     
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, dexCarePatient: DexcarePatient, onCompletion: @escaping VisitCompletion, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) {
        
        self.resumeSuccess = success
        self.visitFailure = failure
        
        Task { @MainActor in
            do {
                try await resumeVirtualVisit(visitId: visitId, presentingViewController: presentingViewController, dexCarePatient: dexCarePatient, onCompletion: onCompletion)
            } catch let error as VirtualVisitFailedReason {
                failure(error)
                cleanupVisitClosures()
            }
        }
    }
    
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, ehrPatient: EhrPatient, onCompletion: @escaping VisitCompletion, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) {
        self.resumeSuccess = success
        self.visitFailure = failure
        
        Task { @MainActor in
            do {
                try await resumeVirtualVisit(visitId: visitId, presentingViewController: presentingViewController, ehrPatient: ehrPatient, onCompletion: onCompletion)
            } catch let error as VirtualVisitFailedReason {
                failure(error)
                cleanupVisitClosures()
            }
        }
    }
    
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, dexCarePatient: DexcarePatient, onCompletion: @escaping VisitCompletion) async throws {
        
        if visitId.isEmpty {
            let error = VirtualVisitFailedReason.missingInformation(message: "visitId must not be empty")
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw error
        }
        
        guard let demographics = dexCarePatient.demographicsLinks.first else {
            let error = VirtualVisitFailedReason.missingInformation(message: "no demographics found in dexcarePatient")
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["patientGuid": dexCarePatient.patientGuid])
            throw error
        }
        
        return try await resumeVirtualVisit(visitId: visitId, presentingViewController: presentingViewController, displayName: demographics.name.display, onCompletion: onCompletion)
    }
    
    func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, ehrPatient: EhrPatient, onCompletion: @escaping VisitCompletion) async throws {
        
        if visitId.isEmpty {
            let error = VirtualVisitFailedReason.missingInformation(message: "visitId must not be empty")
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw error
        }
        
        let patientName = ehrPatient.displayName
        
        return try await resumeVirtualVisit(visitId: visitId, presentingViewController: presentingViewController, displayName: patientName, onCompletion: onCompletion)
    }
    
    private func resumeVirtualVisit(visitId: String, presentingViewController: UIViewController, displayName: String, onCompletion: @escaping VisitCompletion) async throws {
        
        do {
            let existingVirtualVisit = try await fetchExistingVirtualVisit(visitId: visitId)
            
            if existingVirtualVisit.modality == .virtual {
                let permissions = await permissionService.requestPermissions(withVisitType: .virtual)
            
                sendWaitingRoomEvents(visitId: visitId, permissions: permissions)
                guard permissions.granted else {
                    throw VirtualVisitFailedReason.permissionDenied(type: permissions.deniedPermissionType)
                }
            }
                
            // don't care about result as we will complete from inside tokboxManager/phoneManager
            _ = try await startVisitWithResumeVisitResponse(
                existingVirtualVisit,
                presentingViewController: presentingViewController,
                displayName: displayName,
                onCompletion: onCompletion
            )
        } catch {
            let error = VirtualVisitFailedReason.from(error: error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            onVisitFailure(reason: error)
        }
        
    }
    
    func setVirtualEventDelegate(delegate: VirtualEventDelegate?) {
        self.virtualEventDelegate = delegate
    }
    
    private func startVisitWithResumeVisitResponse(_ response: VisitSummary, presentingViewController: UIViewController, displayName: String, onCompletion: @escaping VisitCompletion) async throws -> (String, VirtualVisitModality?) {
        
        guard response.status.isActive() else {
            throw VirtualVisitFailedReason.expired
        }
        
        // return early if the type of visit isn't virtual
        if response.modality != .virtual {
            DispatchQueue.main.async {
                onCompletion(.phoneVisit)
            }
            return (response.visitId, response.modality)
        }
        
        #if DEBUG
        // For debugging only
        NSLog("✳️✳️✳️✳️ -----------------------------------")
        NSLog("✳️✳️✳️✳️ visitId: \(response.visitId)")
        NSLog("✳️✳️✳️✳️ modality: \(response.modality?.rawValue ?? "N/A")")
        NSLog("✳️✳️✳️✳️ waitingRoomSession.sessionId: \(response.tokBoxVisit?.waitingRoomSession.sessionId ?? "N/A")")
        NSLog("✳️✳️✳️✳️ videoConferenceSession.sessionId: \(response.tokBoxVisit?.videoConferenceSession.sessionId ?? "N/A")")
        NSLog("✳️✳️✳️✳️ -----------------------------------")
        #endif
        
        guard
            let tokBoxVisit = response.tokBoxVisit
        else {
            throw VirtualVisitFailedReason.missingInformation(message: "no tokbox visit info found. SDK only supports tokbox visits")
        }
        
        guard let apiKey = tokBoxVisit.apiKey else {
            throw VirtualVisitFailedReason.missingInformation(message: "Missing tokboxVisit.apiKey")
        }
        
        let waitingTokenURL = routes.token(visitId: response.visitId, sessionId: tokBoxVisit.waitingRoomSession.sessionId).token(authenticationToken)
        let videoTokenURL = routes.token(visitId: response.visitId, sessionId: tokBoxVisit.videoConferenceSession.sessionId).token(authenticationToken)
        
        async let waitingTokenResponse: TokBoxTokenResponse = asyncNetworkService.requestObject(waitingTokenURL)
        async let videoTokenResponse: TokBoxTokenResponse = asyncNetworkService.requestObject(videoTokenURL)
        
        var results: (TokBoxTokenResponse, TokBoxTokenResponse)
       
        do {
            results = try await (waitingTokenResponse, videoTokenResponse)
        } catch {
            throw VirtualVisitFailedReason.from(error: error)
        }
        
        let waitingToken = results.0.token
        let videoToken = results.1.token
        let tytoCare = response.tytoCare
        
        self.dexcareConfiguration.serverLogger?.visitId = response.visitId
        
        self.virtualVisitManager = VirtualVisitOpenTokManager(
            virtualService: self,
            displayName: displayName,
            visitId: response.visitId,
            userId: response.userId,
            apiKey: apiKey,
            waitingRoomSessionId: tokBoxVisit.waitingRoomSession.sessionId,
            videoSessionId: tokBoxVisit.videoConferenceSession.sessionId,
            waitingRoomToken: waitingToken,
            videoToken: videoToken,
            inVisitOnResume: response.status == .inVisit,
            navigator: VirtualVisitNavigator(
                presentingViewController: presentingViewController,
                customizationOptions: self.customizationOptions
            ),
            customization: self.customizationOptions,
            tytoCare: tytoCare,
            logger: self.dexcareConfiguration.logger,
            serverLogger: self.dexcareConfiguration.serverLogger,
            completion: { [weak self] reason in
                // only save last patient/visitId if the visit was successfully completed
                if reason == .completed {
                    self?.currentVirtualVisitId = response.visitId
                    self?.currentVirtualPatientId = response.userId
                }
                self?.dexcareConfiguration.serverLogger?.visitId = nil
                
                // send back on main thread
                DispatchQueue.main.async {
                    onCompletion(reason)
                }
            }
        )
        
        // Make sure to register our device token with lion tower endpoint
        // Note: userId is old and response actually returns patientGuid,
        // however edda needs to be updated to support patientGuid vs userId
        self.setupNotificationDeviceToken(userId: response.userId)
        
        return (response.visitId, response.modality)
    }
   
    func updatePushNotificationDeviceToken(_ token: String) {
        // Make the token is different then what we already have
        guard deviceToken != token else { return }
        
        // If there is another device token, make sure to unregister it
        if deviceToken.isNotEmpty {
            deviceNotificationUnregister(deviceToken: deviceToken)
        }
        deviceToken = token
        
        // If there is an existing visit going on, register the device token
        if let userId = virtualVisitManager?.userId {
            setupNotificationDeviceToken(userId: userId)
        }
    }
    
    func updatePushNotificationDeviceToken(token: Data) {
        let tokenString = token.tokenHexStringValue
        
        updatePushNotificationDeviceToken(tokenString)
    }
    
    func postFeedback(feedbacks: [VirtualFeedback], success: @escaping () -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                try await postFeedback(feedbacks: feedbacks)
                success()
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func postFeedback(feedbacks: [VirtualFeedback]) async throws {
        guard let patientId = currentVirtualPatientId else {
            let error = FailedReason.missingInformation(message: "Could not find existing patientId. You must have completed a successful virtual visit in order to post a feedback. Failed to post feedback")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw error
        }
        
        guard let visitId = currentVirtualVisitId else {
            let error = FailedReason.missingInformation(message: "Could not find previous virtual visit. You must have completed a successful virtual visit in order to post a feedback. Failed to post feedback")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw error
        }
        
        do {
            try feedbacks.forEach { feedback in
                try feedback.validate()
            }
        } catch {
            throw FailedReason.missingInformation(message: String(describing: error))
        }
    
        let feedbackData = VirtualFeedbackRequest(patientId: patientId, startTime: currentVirtualStartTime, endTime: currentVirtualEndTime, feedbacks: feedbacks)
        
        let urlRequest = routes.feedback(visitId: visitId).body(json: feedbackData).token(authenticationToken)
        let requestTask = Task { () -> Void in
            return try await asyncNetworkService.requestVoid(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not post feedback: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitId": visitId, "patientGuid": patientId])
            throw FailedReason.from(error: error)
        case .success:
            return
        }
    }
    
    func getEstimatedWaitTime(visitId: String, success: @escaping (WaitTime) -> Void, failure: @escaping (WaitTimeFailedReason) -> Void) {
        Task { @MainActor in
            do {
                let waitTime = try await getEstimatedWaitTime(visitId: visitId)
                success(waitTime)
            } catch let error as WaitTimeFailedReason {
                failure(error)
            }
        }
    }
    
    func getEstimatedWaitTime(visitId: String) async throws -> WaitTime {
        if visitId.isEmpty {
            let error = WaitTimeFailedReason.missingInformation(message: "visitId must not be empty")
            self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            throw error
        }
        
        let urlRequest = routes.waitTime(visitId: visitId).token(authenticationToken)
        let requestTask = Task { () -> WaitTime in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get visit wait time: \(error.localizedDescription)")
            let waitTimeError = WaitTimeFailedReason.from(error: error)
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitId": visitId])
            throw waitTimeError
        case .success(let waitTime):
            return waitTime
        }
    }
    
    func getVirtualVisitStatus(visitId: String, success: @escaping (VisitStatus) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let visitStatus = try await getVirtualVisitStatus(visitId: visitId)
                success(visitStatus)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getVirtualVisitStatus(visitId: String) async throws -> VisitStatus {
        if visitId.isEmpty {
            throw FailedReason.missingInformation(message: "visitId must not be empty")
        }
        
        do {
            return try await fetchExistingVirtualVisit(visitId: visitId).status
        } catch {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitId": visitId])
            throw FailedReason.from(error: error)
        }
    }
    
    func getWaitTimeAvailability(regionCodes: [String]? = nil, assignmentQualifiers: [VirtualVisitAssignmentQualifier]? = nil, visitTypeNames: [VirtualVisitTypeName]? = nil, practiceId: String? = nil, homeMarket: String? = nil, success: @escaping ([WaitTimeAvailability]) -> Void, failure: @escaping (FailedReason) -> Void) {
        
        Task { @MainActor in
            do {
                let waitTimeAvailability = try await getWaitTimeAvailability(regionCodes: regionCodes, assignmentQualifiers: assignmentQualifiers, visitTypeNames: visitTypeNames, practiceId: practiceId, homeMarket: homeMarket)
                success(waitTimeAvailability)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getWaitTimeAvailability(regionCodes: [String]?, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, visitTypeNames: [VirtualVisitTypeName]?, practiceId: String?, homeMarket: String?) async throws -> [WaitTimeAvailability] {
        var options: [URLQueryItem] = []
        
        regionCodes?.forEach { regionCode in
            options.append(URLQueryItem(name: "regionCodes[]", value: regionCode))
        }
        
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
        
        let urlRequest = routes.getWaitTimeAvailability().queryItems(options)
        let requestTask = Task { () -> [WaitTimeAvailability] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not load wait time availability: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["URL": urlRequest.url?.absoluteString ?? "unknown"])
            throw FailedReason.from(error: error)
        case .success(let waitTimeAvailability):
            return waitTimeAvailability
        }
    }
    
    func getAssignmentQualifiers(success: @escaping ([VirtualVisitAssignmentQualifier]) -> Void, failure: @escaping (FailedReason) -> Void) {
        
        Task { @MainActor in
            do {
                let assignmentQualifiers = try await getAssignmentQualifiers()
                success(assignmentQualifiers)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getAssignmentQualifiers() async throws -> [VirtualVisitAssignmentQualifier] {
        let urlRequest = routes.getAssignmentQualifiers()
        
        let requestTask = Task { () -> [VirtualVisitAssignmentQualifier] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not load assignment qualifiers: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["URL": urlRequest.url?.absoluteString ?? "unknown"])
            throw FailedReason.from(error: error)
        case .success(let assignmentQualifiers):
            return assignmentQualifiers
        }

    }
    
    func getModalities(success: @escaping ([VirtualVisitModality]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let modalities = try await getModalities()
                success(modalities)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getModalities() async throws -> [VirtualVisitModality] {
        let urlRequest = routes.getModalities()
        
        let requestTask = Task { () -> [VirtualVisitModality] in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not load modalities: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["URL": urlRequest.url?.absoluteString ?? "unknown"])
            throw FailedReason.from(error: error)
        case .success(let modalities):
            return modalities
        }
    }
    
    // MARK: - Internal Methods
    
    internal func scheduleV9VirtualVisit(request: V9VirtualVisitRequest) async throws -> ScheduleVirtualVisitResponse {
        let urlRequest = routes.scheduleV9().body(json: request).token(authenticationToken)
        
        let requestTask = Task { () -> ScheduleVirtualVisitResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not scheduleV9VirtualVisit: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: VirtualVisitFailedReason.from(error: error), data: nil)
            throw VirtualVisitFailedReason.from(error: error)
        case .success(let response):
            return response
        }
    }
    
    func fetchExistingVirtualVisit(visitId: String) async throws -> VisitSummary {
        let urlRequest = routes.resume(visitId: visitId).token(authenticationToken)
        return try await asyncNetworkService.requestObject(urlRequest)
    }

    func setupNotificationDeviceToken(userId: String) {
        DispatchQueue.main.async { [weak self] in
            if let deviceToken = self?.deviceToken, deviceToken.isNotEmpty {
                self?.tokenPersister.persist(token: deviceToken)
                self?.deviceNotificationRegister(userId: userId, deviceToken: deviceToken)
            } else {
                self?.tokenRegister.registerForRemoteNotifications()
            }
        }
    }
    
    func cleanupNotificationDeviceToken() {
        if let savedToken = tokenPersister.persistedToken {
            deviceNotificationUnregister(deviceToken: savedToken)
            tokenPersister.removePersistedToken()
            deviceToken = ""
        }
    }
    
    func deviceNotificationRegister(userId: String, deviceToken: String) {
        let deviceRequest = RegisterDeviceRequest(userId: userId, deviceId: deviceToken)
        
        let urlRequest = routes.deviceNotificationRegister(appId: dexcareConfiguration.environment.virtualVisitConfiguration.pushNotificationAppId, platform: dexcareConfiguration.environment.virtualVisitConfiguration.pushNotificationPlatform).body(json: deviceRequest)
        
        Task {
            do {
                try await asyncNetworkService.requestVoid(urlRequest)
            } catch {
                dexcareConfiguration.logger?.log("Error registering device token: \(error)", level: .error)
                dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            }
        }
    }
    
    func deviceNotificationUnregister(deviceToken: String) {
        let urlRequest = routes.deviceNotificationUnregister(token: deviceToken, appId: dexcareConfiguration.environment.virtualVisitConfiguration.pushNotificationAppId)
        
        Task {
            do {
                try await asyncNetworkService.requestVoid(urlRequest)
            } catch {
                dexcareConfiguration.logger?.log("Error unregistering device token: \(error)", level: .error)
            }
        }
    }
    
    func cancelVirtualVisit(visitId: String, success: @escaping () -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void) {
        Task { @MainActor in
            do {
                try await cancelVirtualVisit(visitId: visitId)
                success()
            } catch let error as VirtualVisitFailedReason {
                failure(error)
            }
        }
    }
    
    func cancelVirtualVisit(visitId: String) async throws {
        if visitId.isEmpty {
            throw VirtualVisitFailedReason.missingInformation(message: "visitId must not be empty")
        }
        let urlRequest = routes.cancel(visitId: visitId).token(authenticationToken)
        let requestTask = Task {
            return try await asyncNetworkService.requestVoid(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not cancel visit: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: VirtualVisitFailedReason.from(error: error), data: ["visitId": visitId])
            throw VirtualVisitFailedReason.from(error: error)
        case .success:
            return
        }
    }
    
    func postChatMessage(visitId: String, sessionId: String, message: SignalInstantMessage) async throws {
        let requestBody = PostChatRequest(message)
        let urlRequest = routes.chat(visitId: visitId, sessionId: sessionId).body(json: requestBody).token(authenticationToken)
        let requestTask = Task {
            return try await asyncNetworkService.requestVoid(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not cancel visit: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: VirtualVisitFailedReason.from(error: error), data: ["visitId": visitId])
            throw FailedReason.from(error: error)
        case .success:
            return
        }
    }
    
    func onVisitSuccess(visitId: String) {
        visitSuccess?(visitId)
        resumeSuccess?()
        cleanupVisitClosures()
    }
    
    func onVisitFailure(reason: VirtualVisitFailedReason) {
        DispatchQueue.main.async { [weak self] in
            self?.visitFailure?(reason)
            self?.cleanupVisitClosures()
        }
        
    }
    
    private func cleanupVisitClosures() {
        visitSuccess = nil
        resumeSuccess = nil
        visitFailure = nil
    }
    
    // MARK: Integrations - Tytocare
    func pairDevice(visitId: String) async throws -> String {
        let urlRequest = routes.pairDevice(visitId: visitId, accountKey: "tytoCare").token(authenticationToken)
        
        let requestTask = Task { () -> String in
            return try await asyncNetworkService.requestString(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not load tytocare pair device: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["visitId": visitId])
            throw error
        case .success(let response):
            return response
        }
    }
    
    func sendWaitingRoomEvents(visitId: String, permissions: Permissions?) {
        var techCheck = VirtualTechCheck()
        if let permission = permissions {
            techCheck = VirtualTechCheck(withPermissions: permission)
        }
            
        let waitingRoomEvents = WaitingRoomEventsRequest(techCheck: techCheck)
        let urlRequest = routes.waitingRoomEvents(visitId: visitId).token(authenticationToken).body(json: waitingRoomEvents)
        
        dexcareConfiguration.logger?.log("Sending tech check: \(techCheck)")
        Task {
            do {
                try await asyncNetworkService.requestVoid(urlRequest)
            } catch {
                dexcareConfiguration.logger?.log("Error sending waiting room events: \(error)", level: .error)
            }
        }
    }
    
    // MARK: NetworkStats
    func getVideoCallStatistics() -> VideoCallStatistics? {
        return virtualVisitManager?.networkStats
    }
}

extension V9VirtualVisitRequest {
    init?(
        billingInformation: BillingInformation,
        virtualVisitDetails: VirtualVisitDetails,
        patient: EhrPatient,
        actor: EhrPatient?,
        customization: CustomizationOptions? = CustomizationOptions(validateEmails: true)
    ) throws {

        try virtualVisitDetails.validate(validateEmail: customization?.validateEmails ?? true)
        var visitPatient = patient
        var visitActor = actor
        
        // Update the patient phone with what was sent specifically in VisitDetails
        visitPatient.phone = virtualVisitDetails.contactPhoneNumber
        visitPatient.email = virtualVisitDetails.userEmail
        // homeMarket is requested through visitDetails, but api requires it through patient
        visitPatient.homeMarket = virtualVisitDetails.homeMarket
        try visitPatient.validate()
        
        visitActor?.phone = virtualVisitDetails.contactPhoneNumber
        visitActor?.email = virtualVisitDetails.userEmail
        visitActor?.relationshipToPatient = virtualVisitDetails.actorRelationshipToPatient
        try visitActor?.validate()

        if virtualVisitDetails.patientDeclaration == .other && visitActor == nil {
            throw "actor must not be nil when patientDeclaration == other"
        }
        if virtualVisitDetails.patientDeclaration == .other && visitActor?.relationshipToPatient == nil {
            throw "relationshipToPatient must not be nil when patientDeclaration == other"
        }
        self.init(patient: visitPatient, actor: visitActor, visitDetails: virtualVisitDetails, billingInfo: billingInformation, additionalDetails: virtualVisitDetails.additionalDetails)
    }
}
