// Copyright © 2019 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
/// A structure holding information about an Insurance Payer that the system supports
public struct InsurancePayer: Equatable, Codable {
    /// A string representing the name of the Insurance Payer
    public let name: String
    /// A unique id for the insurance payer
    /// This property can be used in `PaymentMethod`
    public let payerId: String
}

struct InsurancePayerResponse: Decodable, Equatable {
    var payers: [InsurancePayer]

    enum CodingKeys: String, CodingKey {
        case insuranceIssuers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if container.contains(.insuranceIssuers) {
            payers = try container.decode([InsurancePayer].self, forKey: .insuranceIssuers)
        } else {
            payers = []
        }
    }
}
