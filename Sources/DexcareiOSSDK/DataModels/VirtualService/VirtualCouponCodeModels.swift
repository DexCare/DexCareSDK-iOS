// Copyright © 2019 DexCare. All rights reserved.

import Foundation

struct CouponCodeResponse: Decodable, Equatable {
    enum Status: String, Codable {
        case active
        case inactive
    }

    let status: Status

    /// Discount amount in pennies
    let discountAmount: Int
}
