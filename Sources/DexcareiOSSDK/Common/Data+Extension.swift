// Copyright © 2020 Providence. All rights reserved.

import Foundation

extension Data {
    /// Converts device token data to a hex string
    public var tokenHexStringValue: String {
        return map { String(format: "%02.2hhx", $0) }.joined()
    }
}
