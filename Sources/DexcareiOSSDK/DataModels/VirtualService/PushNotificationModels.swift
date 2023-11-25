// Copyright © 2019 Providence. All rights reserved.

import Foundation

struct RegisterDeviceRequest: Codable, Equatable {
    
    let userId: String
    /** Device token (ios) or registration ID (android) */
    let deviceId: String
}
