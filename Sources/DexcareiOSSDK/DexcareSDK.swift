// Copyright © 2019 Providence. All rights reserved.

import Foundation

/// A structure defining a DexcareSDK Environment
public struct Environment {
    /// the base url for any calls to the fhirOrch service
    public let fhirOrchUrl: URL
    /// configuration to set up the Virtual Visit Service
    public let virtualVisitConfiguration: VirtualVisitConfiguration
    /// the api key used in api calls
    public let dexcareAPIKey: String
    
    public init(
        fhirOrchUrl: URL, 
        virtualVisitConfiguration: VirtualVisitConfiguration, 
        dexcareAPIKey: String
    ) {
        self.fhirOrchUrl = fhirOrchUrl
        self.virtualVisitConfiguration = virtualVisitConfiguration
        self.dexcareAPIKey = dexcareAPIKey
    }
}

/// Information to set up the Virtual Visit Service
public struct VirtualVisitConfiguration {
    /// AppId used to register for push notifications for the Virtual Visit Service
    public let pushNotificationAppId: String
    /// Platform used to register for push notifications for the Virtual Visit Service
    public let pushNotificationPlatform: String
    /// The base url for the virtual visit service
    public let virtualVisitUrl: URL
    
    public init(
        pushNotificationAppId: String, 
        pushNotificationPlatform: String, 
        virtualVisitUrl: URL
    ) {
        self.pushNotificationAppId = pushNotificationAppId
        self.pushNotificationPlatform = pushNotificationPlatform
        self.virtualVisitUrl = virtualVisitUrl
    }
}

/// The main configuration structure used in initializing the DexcareSDK
public struct DexcareConfiguration {
    /// Specific URL's and Keys are setup here
    public let environment: Environment

    /// Used in UserAgent api calls in the header
    public let userAgent: String
    /// value added as the `domain` header on all api calls
    public let domain: String
        
    /// Used to display information inside the console.
    public let logger: DexcareSDKLogger?
    
    /// Used to log various info to the server on certain cases.
    // Keeping it in DexcareConfig so that it can be easier used across services.
    internal var serverLogger: LoggingService?
    
    public init(
        environment: Environment,
        userAgent: String,
        domain: String,
        logger: DexcareSDKLogger? = nil
    ) {
        self.environment = environment
        self.userAgent = userAgent
        self.domain = domain
        self.logger = logger
    }
    
    // for internal stubbing.
    init(
        environment: Environment,
        userAgent: String,
        domain: String,
        logger: DexcareSDKLogger? = nil,
        serverLogger: LoggingService? = nil
    ) {
        self.environment = environment
        self.userAgent = userAgent
        self.domain = domain
        self.logger = logger
        self.serverLogger = serverLogger
    }
}

/// The main class to initialize to use the DexCare Mobile SDK.
public class DexcareSDK {
    
    /// An instance of the `PatientService` protocol
    public var patientService: PatientService {
        return internalPatientService
    }
    internal var internalPatientService: PatientServiceSDK
    
    /// An instance of the `AppointmentService` protocol
    public var appointmentService: AppointmentService {
        return internalAppointmentService
    }
    internal var internalAppointmentService: AppointmentServiceSDK
    
    /// An instance of the `VirtualService` protocol
    public var virtualService: VirtualService {
        return internalVirtualService
    }
    internal var internalVirtualService: VirtualServiceSDK
    
    /// An instance of the `RetailService` protocol
    public var retailService: RetailService {
        return internalRetailService
    }
    internal var internalRetailService: RetailServiceSDK
    
    /// An instance of the `PracticeService` protocol
    public var practiceService: PracticeService {
        return internalPracticeService
    }
    internal var internalPracticeService: PracticeServiceSDK
    
    /// An instance of the `ProviderService` protocol
    public var providerService: ProviderService {
        return internalProviderService
    }
    internal var internalProviderService: ProviderServiceSDK
    
    /// An instance of the `PaymentService` protocol
    public var paymentService: PaymentService {
        return internalPaymentService
    }
    internal var internalPaymentService: PaymentServiceSDK
    
    /// An instance of the `AvailabilityService` protocol
    public var availabilityService: AvailabilityService {
        return internalAvailabilityService
    }
    internal var internalAvailabilityService: AvailabilityServiceSDK
    
    /// The object that acts as the refreshTokenDelegate of the DexcareSDK
    ///
    /// The refreshTokenDelegate must adopt the RefreshTokenDelegate protocol. The sdk maintains a weak reference to the refreshTokenDelegate object.
    /// The refreshTokenDelegate object is responsible for requesting a new OAuth2 Token from the client when a network call receives a 401.
    /// - Note: if the refreshTokenDelegate is not set the calls will simply pass down the 401 to the client.
    public weak var refreshTokenDelegate: RefreshTokenDelegate? {
        didSet {
            updateErrorHandlers()
        }
    }
        
    /// A set of options used by the SDK for UI changes, integration setup, various config options.
    public var customizationOptions: CustomizationOptions? {
        didSet {
            internalVirtualService.customizationOptions = customizationOptions
            internalRetailService.customizationOptions = customizationOptions
            internalProviderService.customizationOptions = customizationOptions
        }
    }
    
    private var networkObserver: NotificationObserver?
    internal var configuration: DexcareConfiguration
    
    internal var pantryService: PantryService {
        return internalPantryService
    }
    internal var internalPantryService: PantryServiceSDK
    
    public init(configuration: DexcareConfiguration) {
        let fhirOrchRequestModifiers = DexcareSDK.fhirOrchRequestModifiers(configuration: configuration)
        self.configuration = configuration
        
        self.configuration.serverLogger = LoggingServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        
        self.internalRetailService = RetailServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        self.internalVirtualService = VirtualServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
         
        self.internalAppointmentService = AppointmentServiceSDK(
            configuration: self.configuration,
            requestModifiers: fhirOrchRequestModifiers
        )
        self.internalPatientService = PatientServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        
        self.internalPracticeService = PracticeServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        self.internalProviderService = ProviderServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        self.internalPaymentService = PaymentServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        
        self.internalPantryService = PantryServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        
        self.internalAvailabilityService = AvailabilityServiceSDK(configuration: self.configuration, requestModifiers: fhirOrchRequestModifiers)
        
        // setup Observers for network calls
        setupObservers()
        
        // load any configs we need to from the server
        internalPantryService.getValidationConfigs()
    }
    
    /// Sets the bearer token for the majority of subsequent calls to the dexcare platform.
    ///
    /// A valid 0Auth2 token is required for the majority of the SDK calls.
    /// - Parameters:
    ///   - accessToken: an OAuth2 token used for all calls
    public func signIn(accessToken: String) {
        postNotification(notification: refreshTokenNotification, value: accessToken)
    }
    
    /// Removes the bearer token for the calls.
    ///
    /// Removes any cached values
    /// A valid 0Auth2 token is required for the majority of the SDK calls.
    public func signOut() {
        postNotification(notification: refreshTokenNotification, value: "")
        
        internalVirtualService.currentVirtualVisitId = nil
        internalVirtualService.currentVirtualPatientId = nil
        internalVirtualService.currentVirtualStartTime = nil
        internalVirtualService.currentVirtualEndTime = nil
        
        internalVirtualService.virtualVisitManager = nil
    }
    
    /// Gets the latest status of the DexCare services
    ///
    /// `DexcareStatus` can be used to block certain functions of your app if there is a major incident, or have warnings about possible issues. The DexcareSDK platform does not use this status for any blocking calls.
    /// Results are cached, and are updated when any incidents or scheduled maintenances are happening on the DexCare platform.
    /// - Parameters:
    ///   - success: a closure called with the `DexcareStatus` object representing the status of the DexCare platform
    ///   - failure: a closure called when the call to get the status fails. If this happens, please contact us.
    public func getDexcareStatus(success: @escaping (DexcareStatus) -> Void, failure: @escaping (FailedReason) -> Void) {
        pantryService.getStatusPage(success: success, failure: failure)
    }
    public func getDexcareStatus() async throws -> DexcareStatus {
        return try await pantryService.getStatusPage()
    }
    
    //
    // Internal Functions
    //

    internal func updateErrorHandlers() {
        let tokenRefreshErrorHandlerAsync = AsyncTokenRefresher(delegate: refreshTokenDelegate, logger: configuration.logger) { [weak self] token in
            self?.signIn(accessToken: token)
        }
        
        // Async Error Handlers
        internalPantryService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalPracticeService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalPaymentService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalRetailService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalAppointmentService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalProviderService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalPatientService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalVirtualService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
        internalAvailabilityService.asyncErrorHandlers = [tokenRefreshErrorHandlerAsync]
    }
    
    internal static func fhirOrchRequestModifiers(configuration: DexcareConfiguration) -> [NetworkRequestModifier] {
        var modifiers = standardRequestModifiers(configuration: configuration)
        
        // Add a "x-api-key' to the header for FhirOrch calls
        modifiers.append(OrchestrationApiKeyRequestModifier(apiKey: configuration.environment.dexcareAPIKey))
        
        return modifiers
    }
    
    internal static func standardRequestModifiers(configuration: DexcareConfiguration) -> [NetworkRequestModifier] {
        return [
            // Add a `User-Agent` header to identify brand, version, platform etc
            UserAgentNetworkRequestModifier(userAgentName: "\(configuration.userAgent)"),
            // Add a `Domain` header to identify epic and brand
            DomainNetworkRequestModifier(domain: configuration.domain),
            // Add a `product` url parameter to identify platform
            ProductIdentifyingRequestModifier(),
            // Add a `CorrelationId` to header
            CorrelationIdRequestModifier()
        ]
    }
    
    internal func setupObservers() {
        networkObserver = NotificationObserver(notification: networkTaskDidCompleteNotification) { [weak self] (taskComplete: TaskComplete) in
            if let response = taskComplete.response {
                var level = DexcareSDKLogLevel.debug
                if response.statusCode >= 300 {
                    level = .error
                }
                var correlationId: String?
                if #available(iOS 13.0, *) {
                    correlationId = response.value(forHTTPHeaderField: CorrelationIdRequestModifier.correlationIdField)
                } else {
                    correlationId = response.allHeaderFields[CorrelationIdRequestModifier.correlationIdField] as? String
                }
                
                let durationString = String(format: "%.2f", taskComplete.elapsedTime ?? 0)
                self?.configuration.logger?.log("Response \(level) in \(durationString)s for: \(response.url?.absoluteString ?? "") - Status: \(response.statusCode) - Correlation: \(correlationId ?? "")", level: level)
                
                self?.configuration.serverLogger?.lastCorrelationId = correlationId
            }
        }
 
    }
}

public typealias TokenRequestCallback = ((String?) -> (Void))

/// The RefreshTokenDelegate protocol defines methods that allow you to handle any 401 errors that may return from network calls.
public protocol RefreshTokenDelegate: AnyObject {
    /// Asks the refreshTokenDelegate for a new OAuth2 token
    ///
    /// If the `DexcareSDK.refreshTokenDelegate` property is set, this function will get called when a network call receives a 401 error code.
    /// The SDK will call this method, and wait for a response infinitely. It is up to you to call the `tokenCallback` with a nil or a valid token
    /// If this function returns a nil, the sdk will automatically revert the original request to it's originating error and return.
    /// If a new token is set, the sdk will set it's Authorization header with the new token and retry the request. Any subsequent 401 errors will revert back to the original error, and NOT call this method again.
    /// You may also pass through a nil string if you need to return quickly from this function.
    /// - Parameters:
    ///    - tokenCallback: A callback that sends the new token
    func newTokenRequest(tokenCallback: @escaping TokenRequestCallback)
}
