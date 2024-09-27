//
//  BlisseyConfigs.swift
//  DexcareiOSSDK
//
//  Created by Daniel Johns on 2024-02-13.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

struct InternalCancelReason: Decodable {
    static let `default`: Self = .init(label: "Other", value: "OTHER")

    let label: String
    let value: String

    var cancelReason: CancelReason {
        .init(displayText: label, code: value)
    }
}

extension Array where Element == InternalCancelReason {
    var cancelReasons: [CancelReason] {
        self.map { .init(displayText: $0.label, code: $0.value) }
    }
}

struct VisitCancelReasons: Decodable {
    let reasons: [String: [InternalCancelReason]]
}

struct FeatureFlags: Decodable {
    struct EnablePatientCancellationWithReason: Decodable {
        let video: Bool
        let phone: Bool
    }

    let enablePatientCancellationWithReason: EnablePatientCancellationWithReason
}

struct BlisseyConfigs: Decodable {
    let minimumWaitTimeForWaitOffline: Int
    let cancelWithReason: VisitCancelReasons
    let blisseyPostConsultUrl: String
    let featureFlags: FeatureFlags
}
