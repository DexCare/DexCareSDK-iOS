//
//  ModalityConversion.swift
//  DexcareiOSSDK
//
//  Created by Dominic Pepin on 2024-07-12.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

/// Payload attached to a ModalityConversion open tok event.
struct ModalityConversion: Decodable {
    var targetModality: VirtualVisitModality

    enum CodingKeys: String, CodingKey {
        case targetModality
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let modalityString = try? container.decode(String.self, forKey: .targetModality) {
            targetModality = VirtualVisitModality(rawValue: modalityString)
        } else {
            targetModality = VirtualVisitModality(rawValue: "unknown")
        }
    }
}
