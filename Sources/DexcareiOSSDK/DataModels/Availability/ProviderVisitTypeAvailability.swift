//
// ProviderVisitTypeAvailability.swift

import Foundation

/// Health System defined VisitType used in Provider Availability
public struct ProviderVisitTypeAvailability: Codable, Equatable {
    /// What type of `ProviderVisitType` that the provider supports
    public let visitType: ProviderVisitType // Current SDK Class, so custom decode based on ID/Name
    /// Counts of any availability the provider has
    public let availability: ProviderAvailabilitySlotWindow
    
    private let visitTypeId: String
    private let visitTypeName: String
    
    /// An internal decoder
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.visitTypeId = try values.decode(String.self, forKey: CodingKeys.visitTypeId)
        self.visitTypeName = try values.decode(String.self, forKey: CodingKeys.visitTypeName)
        
        self.visitType = ProviderVisitType(visitTypeId: visitTypeId, name: visitTypeName, shortName: nil, description: nil)
        
        self.availability = try values.decode(ProviderAvailabilitySlotWindow.self, forKey: CodingKeys.availability)
    }
}

/// Information on the Provider Availability
public struct ProviderAvailabilitySlotWindow: Codable, Equatable {
    /// How many open days the provider has
    public let windowDays: Int?
    /// How many open slots the provider has
    public let slotCount: Int?
}
