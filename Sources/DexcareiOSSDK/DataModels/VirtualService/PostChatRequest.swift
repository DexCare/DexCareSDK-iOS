//
// PostChatRequest.swift
// DexcareSDK
//
// Created by Reuben Lee on 2020-03-16.
// Copyright © 2020 Providence. All rights reserved.
//

import Foundation

struct PostChatRequest: Encodable {
    var type: String = SignalMessageType.instantMessage.rawValue
    var data: SignalInstantMessage
    
    init(_ data: SignalInstantMessage) {
        self.data = data
    }
}
