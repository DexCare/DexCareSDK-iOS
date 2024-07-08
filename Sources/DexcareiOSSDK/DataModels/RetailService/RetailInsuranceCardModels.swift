// Copyright © 2019 DexCare. All rights reserved.

import Foundation

struct InsuranceCardV2CreateResponse: Codable, Equatable {
    let id: String
}

enum InsuranceCardOrientation: String {
    case front
    case back
}
