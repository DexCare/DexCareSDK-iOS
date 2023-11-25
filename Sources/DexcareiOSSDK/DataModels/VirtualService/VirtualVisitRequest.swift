//
// VirtualVisitRequest.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2021-08-30.
// Copyright © 2021 Providence. All rights reserved.
//

import Foundation

struct V9VirtualVisitRequest: Encodable, Equatable {
    var patient: EhrPatient
    var actor: EhrPatient?
    var visitDetails: VirtualVisitDetails
    var billingInfo: BillingInformation
    var additionalDetails: AdditionalDetails?
   
    enum CodingKeys: String, CodingKey {
        case patient
        case actor
        case visitDetails
        case billingInfo
        case additionalDetails
    }
    
    /// custom encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(patient, forKey: .patient)
        try container.encodeIfPresent(actor, forKey: .actor)
        try container.encode(visitDetails, forKey: .visitDetails)
        try container.encode(billingInfo, forKey: .billingInfo)
        
        var extraDetails: [V9AdditionalDetails]? = []
        
        additionalDetails?.forEach {
            extraDetails?.append(V9AdditionalDetails(key: $0.key, value: $0.value))
        }
        if let extraDetails = extraDetails, extraDetails.count > 0 {
            try container.encodeIfPresent(extraDetails, forKey: .additionalDetails)
        }
    }
}

struct V9AdditionalDetails: Encodable {
    let key: String
    let value: String
}
