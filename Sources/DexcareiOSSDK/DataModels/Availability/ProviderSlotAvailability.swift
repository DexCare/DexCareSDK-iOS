//
// ProviderSlotAvailability.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2022-10-14.
// Copyright © 2022 Providence. All rights reserved.
//

import Foundation

///
public struct ProviderSlotAvailability: Equatable {
    /// Array of `AggregatedSlot`
    public let slots: [AggregatedSlot]
    /// A context that can be used
    public let searchContext: String
    
}

extension ProviderSlotAvailability {
    
    internal init(withInternalResponse response: SlotAvailabilityResponse) {
        var slots: [AggregatedSlot] = []
        
        response.slots.forEach { slot in
            
            let providerOptions: [ProviderOptions] = slot.providerOptions.compactMap { option in
                guard let provider = response.providers[option.npi] else { return nil }
                guard let department = response.departments[option.departmentEhrIdentifier] else { return nil }

                let providerAvailability = ProviderAvailability(
                    npi: option.npi,
                    provider: provider,
                    department: department)
                
                return ProviderOptions(
                    visitTypeId: option.visitTypeId,
                    provider: providerAvailability,
                    duration: option.duration
                )
            }
            let publicSlot = AggregatedSlot(
                slotDateTime: slot.slotDateTime,
                providerOptions: providerOptions,
                visitTypeName: slot.visitTypeName)
            
            slots.append(publicSlot)
        }
        
        self.slots = slots
        self.searchContext = response.searchContext
        
    }
}

// Internal decoding helpers as we are converting the json response to a more usable format for the client
internal struct SlotAvailabilityResponse: Decodable, Equatable {
    let slots: [InternalAggregatedSlot]
    let providers: [String: AvailabilityProviderResponse]
    let departments: [String: AvailabilityDepartmentResponse]
    let searchContext: String
    
    enum CodingKeys: CodingKey {
        case slots
        case providers
        case departments
        case searchContext
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.slots = try container.decode([InternalAggregatedSlot].self, forKey: .slots)
        self.providers = try container.decode([String: AvailabilityProviderResponse].self, forKey: .providers)
        self.departments = try container.decode([String: AvailabilityDepartmentResponse].self, forKey: .departments)
        self.searchContext = try container.decode(String.self, forKey: .searchContext)
    }
}

internal struct InternalAggregatedSlot: Decodable, Equatable {
    let slotDateTime: Date
    let visitTypeName: String
    let providerOptions: [InternalProviderOptions]
    
    enum CodingKeys: CodingKey {
        case slotDateTime
        case visitTypeName
        case providerOptions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let startDateTimeString = try container.decode(String.self, forKey: CodingKeys.slotDateTime)
        if let startDateTime = DateFormatter.iso8601NoMilliseconds.date(from: startDateTimeString) {
            self.slotDateTime = startDateTime
        } else {
            throw "Invalid startDate format"
        }
 
        self.visitTypeName = try container.decode(String.self, forKey: .visitTypeName)
        self.providerOptions = try container.decode([InternalProviderOptions].self, forKey: .providerOptions)
    }
}

internal struct InternalProviderOptions: Decodable, Equatable {
    let npi: String
    let departmentEhrIdentifier: String
    let duration: Int
    let visitTypeId: String
}
    
internal struct AvailabilityProviderResponse: Decodable, Equatable {
    let name: String
    let gender: String?
    let specialties: [String]
}

internal struct AvailabilityDepartmentResponse: Decodable, Equatable {
    let departmentId: String
    let departmentName: String
    let distanceFrom: Double
    let ehrInstance: String
    let clinicType: String
    let timezone: String
    let address: Address
}
