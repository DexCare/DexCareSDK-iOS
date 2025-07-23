//
//  URLParamString.swift
//  DexcareiOSSDK
//
//  Created by Alex Maslov on 2024-07-25.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

extension String {
    func replacingPlaceholders(with values: [String: String]) -> String {
        var result = self
        for (key, value) in values {
            result = result.replacingOccurrences(of: "{{\(key)}}", with: value)
        }
        return result
    }
}
