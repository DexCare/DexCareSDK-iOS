// Copyright © 2020 DexCare. All rights reserved.

import Foundation

class AsyncTokenRefresher: AsyncNetworkErrorHandler {
    
    let logger: DexcareSDKLogger?
    weak var unauthorizedDelegate: RefreshTokenDelegate?
    let tokenCallback: ((String) -> Void)
    
    init(delegate: RefreshTokenDelegate?, logger: DexcareSDKLogger?, tokenCallback: @escaping ((String) -> Void)) {
        self.unauthorizedDelegate = delegate
        self.logger = logger
        self.tokenCallback = tokenCallback
    }
    
    func canHandle(_ error: Error) -> Bool {
        return error.isNetworkError(withStatusCode: 401) && self.unauthorizedDelegate != nil
    }
    
    func handle(_ error: Error) async throws {
        if let delegate = unauthorizedDelegate {
            logger?.log("Unauthorized delegate set, requesting new token", level: .info)
            
            let requestedNewToken = await withCheckedContinuation({ (continuation: CheckedContinuation<String?, Never>) in                
                delegate.newTokenRequest { requestedNewToken in
                    continuation.resume(returning: requestedNewToken)
                }
            })
            
            if let token = requestedNewToken {
                self.tokenCallback(token)
                self.logger?.log("Retrieved new token. Trying request again.", level: .info)
                return
            } else {
                logger?.log("No new token - erroring original request.", level: .info)
                throw error
            }

        } else {
            logger?.log("No Unauthorized Delegate set to retry, erroring original request", level: .info)
            throw error
        }
    }
}
