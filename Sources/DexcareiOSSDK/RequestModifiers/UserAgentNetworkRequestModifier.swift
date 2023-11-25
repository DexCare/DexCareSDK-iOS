// Copyright © 2019 Providence. All rights reserved.

import Foundation
import UIKit

class UserAgentNetworkRequestModifier: NetworkRequestModifier {

    /// User agent in the format: **App Name|App Version|Device Model|iOS Version|darwin**
    ///
    /// Example: `Swedish Mobile|6.0.0|iPhone|12.1|darwin`
    ///
    /// The custom user agent should support the following regular expressions for proper API functionality:
    ///  - `/\s+Mobile\|\d\.\d\.\d\|/`
    ///    - This is to identify when a mobile app is scheduling a retail appointment to customize the email confirmation. See https://jira.dig.engineering/browse/LTW-2681.
    ///  - `*darwin*`
    ///    - This was formerly used to differentiate iOS and Android devices, as the default iOS user agent includes `"darwin"`
    static func userAgentHeaderValue(_ userAgentName: String) -> String {

        let version = DexcareAppVersion.version ?? "0.0.0"

        let device = UIDevice.current

        let hardCodedDarwin = "darwin" // N.B. expected by some APIs
        
        let sdkVersion = DexcareAppVersion.sdkVersion ?? "0.0.0"
        return [userAgentName, version, device.model, device.systemVersion, "iOSSDK", sdkVersion, hardCodedDarwin].joined(separator: "|") // N.B. order is intentional
    }

    let userAgentName: String

    init(userAgentName: String) {
        self.userAgentName = userAgentName
    }

    func mutate(_ request: URLRequest) -> URLRequest {
        var result = request
        result.addValue(UserAgentNetworkRequestModifier.userAgentHeaderValue(userAgentName), forHTTPHeaderField: "User-Agent")
        return result
    }
}
