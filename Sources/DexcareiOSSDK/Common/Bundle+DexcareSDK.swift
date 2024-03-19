// Copyright © 2019 Providence. All rights reserved.

import Foundation

extension Bundle {
    static var dexcareSDK: Bundle {
        let currentBundle = Bundle.module
        
        // Because OpenTok is a static framework,
        // We may need to expose Dexcare as a static framework/resource bundle for development
        // In that case, the bundle resources are located in a separate bundle
        if let url = currentBundle.url(forResource: "DexcareSDK", withExtension: "bundle"),
           let dexcareBundle = Bundle(url: url) {
            return dexcareBundle
        } else {
            return currentBundle
        }
    }
}

func localizeString(_ key: String, comment: String = "") -> String {
    // check to see if the client has overridden the key, if not, use the SDK version
    let stringValue = NSLocalizedString(key, comment: comment)
    if stringValue != key {
        return stringValue
    } else {
        return NSLocalizedString(key, bundle: .dexcareSDK, comment: comment)
    }
}
