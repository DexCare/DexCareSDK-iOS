// Copyright © 2020 DexCare. All rights reserved.

import Foundation

public extension Data {
    /// Converts device token data to a hex string
    var tokenHexStringValue: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
