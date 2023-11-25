import Foundation

protocol PantryService {
    func getValidationConfigs()

    func getStatusPage(success: @escaping (DexcareStatus) -> Void, failure: @escaping (FailedReason) -> Void)
    
    func getStatusPage() async throws -> DexcareStatus
}

class PantryServiceSDK: PantryService {
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
        
        func getValidationConfigs() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("v1/validationConfigs")
        }
        
        func getStatusPage() -> URLRequest {
            return dexcareRoute.fhirBuilder.get("v1/statuspage")
        }
    }
    
    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
    }
    
    func getValidationConfigs() {
        let urlRequest = routes.getValidationConfigs()
    
        Task {
            do {
                let configs: ValidationConfigs = try await asyncNetworkService.requestObject(urlRequest)
                if let emailRegex = configs.emailValidationRegex {
                    EmailValidator.emailValidationRegex = emailRegex
                }
            } catch {
                self.dexcareConfiguration.logger?.log("Could not download validation configs")
                self.dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            }
        }
    }
    
    func getStatusPage(success: @escaping (DexcareStatus) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let status = try await getStatusPage()
                success(status)
            } catch {
                
                let failedReason = FailedReason.from(error: error)
                failure(failedReason)
            }
        }
    }
    
    // MARK: ASYNC
    func getStatusPage() async throws -> DexcareStatus {
        let urlRequest = routes.getStatusPage()

        let requestTask = Task { () -> DexcareStatus in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not download status page")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error)
            
            throw FailedReason.from(error: error)
            
        case .success(let status):
            return status
        }
    }
}
