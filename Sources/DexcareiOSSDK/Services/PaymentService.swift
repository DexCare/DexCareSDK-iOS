import Foundation
import UIKit

/// Base Protocol to get Payment Information
public protocol PaymentService {
    
    /// Fetches the list of `InsurancePayer` associated with the tenant
    /// - Parameters:
    ///   - tenant: A string to indicate which tenant you want the list of `InsurancePayer` for
    ///   - success: A closure called with a list of `InsurancePayer`
    ///   - failure: A closure called if any FailedReason errors are returned
    func getInsurancePayers(tenant: String, success: @escaping ([InsurancePayer]) -> Void, failure: @escaping (FailedReason) -> Void)
    
    /// Validates the coupon code (sometimes called service key) and returns the amount of the coupon
    /// - Parameters:
    ///   - couponCode: A string to indicate the coupon code (sometimes called service key) used for verification
    ///   - success: A closure called with a Decimal of the coupon amount in dollars. ie. 49.00 for $49
    ///   - failure: A closure called if any CouponCodeFailedReason errors are returned
    func verifyCouponCode(couponCode: String, success: @escaping (Decimal) -> Void, failure: @escaping (CouponCodeFailedReason) -> Void)
        
    // Async Equivalents
    /// Fetches the list of `InsurancePayer` associated with the tenant
    /// - Parameters:
    ///   - tenant: A string to indicate which tenant you want the list of `InsurancePayer` for
    /// - Throws: `FailedReason`
    /// - Returns: An array of `InsurancePayer`
    func getInsurancePayers(tenant: String) async throws -> [InsurancePayer]
    
    /// Validates the coupon code (sometimes called service key) and returns the amount of the coupon
    /// - Parameters:
    ///   - couponCode: A string to indicate the coupon code (sometimes called service key) used for verification
    /// - Throws:`CouponCodeFailedReason`
    /// - Returns:Decimal of the coupon amount in dollars. ie. 49.00 for $49
    func verifyCouponCode(couponCode: String) async throws -> Decimal
}

class PaymentServiceSDK: PaymentService {
    
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
        
        // MARK: - Insurance
        
        func insurancePayers(tenant: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/v2/brand/\(tenant)/insuranceissuers")
        }
        
        // MARK: - Coupon Code
        
        func verifyCouponCode(couponCode: String) -> URLRequest {
            return dexcareRoute.lionTowerBuilder.get("/api/v2/coupon/\(couponCode)/verify")
        }
    }
    
    init(configuration: DexcareConfiguration, requestModifiers: [NetworkRequestModifier]) {
        self.dexcareConfiguration = configuration
        self.routes = Routes(dexcareRoute: DexcareRoute(environment: configuration.environment))
        self.asyncNetworkService = AsyncHTTPNetworkService(requestModifiers: requestModifiers)
        self.authenticationToken = ""
    }
    
    func getInsurancePayers(tenant: String, success: @escaping ([InsurancePayer]) -> Void, failure: @escaping (FailedReason) -> Void) {
        Task { @MainActor in
            do {
                let insurancePayers = try await getInsurancePayers(tenant: tenant)
                success(insurancePayers)
            } catch let error as FailedReason {
                failure(error)
            }
        }
    }
    
    func getInsurancePayers(tenant: String) async throws -> [InsurancePayer] {
        if tenant.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: FailedReason.missingInformation(message: "tenant must not be empty"))
            throw FailedReason.missingInformation(message: "tenant must not be empty")
        }
        
        let urlRequest = routes.insurancePayers(tenant: tenant)
        let requestTask = Task { () -> InsurancePayerResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get insurance payer info: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["tenant": tenant])
            throw FailedReason.from(error: error)
        case .success(let insurancePayers):
            return insurancePayers.payers
        }
    }
    
    func verifyCouponCode(couponCode: String, success: @escaping (Decimal) -> Void, failure: @escaping (CouponCodeFailedReason) -> Void) {
        
        Task { @MainActor in
            do {
                let couponCode = try await verifyCouponCode(couponCode: couponCode)
                success(couponCode)
            } catch let error as CouponCodeFailedReason {
                failure(error)
            }
        }
    }
    
    func verifyCouponCode(couponCode: String) async throws -> Decimal {
        if couponCode.isEmpty {
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: CouponCodeFailedReason.missingInformation(message: "couponCode must not be empty"))
            throw CouponCodeFailedReason.missingInformation(message: "couponCode must not be empty")
        }
        
        let encodedCouponCode = couponCode.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        let urlRequest = routes.verifyCouponCode(couponCode: encodedCouponCode)
        
        let requestTask = Task { () -> CouponCodeResponse in
            return try await asyncNetworkService.requestObject(urlRequest)
        }
        let result = await requestTask.result
        
        switch result {
        case .failure(let error):
            dexcareConfiguration.logger?.log("Could not get insurance payer info: \(error.localizedDescription)")
            dexcareConfiguration.serverLogger?.postErrorIfNeeded(error: error, data: ["couponcode": couponCode])
            throw CouponCodeFailedReason.from(error: error)
        case .success(let response):
            guard response.status == .active else { throw CouponCodeFailedReason.inactive }
            
            return Decimal(response.discountAmount) / 100.0
        }
    }
}
