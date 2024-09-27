//
//  WaitOfflineRequest.swift
//  DexcareiOSSDK
//
//  Created by Daniel Johns on 2024-02-05.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation

struct WaitOfflineRequest: Encodable {
    struct WaitOfflineRequestBody: Encodable {
        let visitId: String
        let practiceId: String
        let sessionId: String
    }

    let action = "patientEnterWaitOffline"
    let data: WaitOfflineRequestBody

    init(visitId: String, practiceId: String, sessionId: String) {
        data = WaitOfflineRequestBody(visitId: visitId, practiceId: practiceId, sessionId: sessionId)
    }
}
