//
// Provider.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2021-01-11.
// Copyright © 2021 DexCare. All rights reserved.
//

import Foundation

/// A structure containing information about a health-care provider
public struct Provider: Codable {
    /// The national identifier for this Provider
    public let providerNationalId: String
    /// The full name of the `Provider`
    public let name: String
    
    /// The qualification of this Provider, ex: "MD"
    public let credentials: String?
    /// The minimum age a patient must be in order to visit this Provider.
    public let minAge: Int?
    /// The maximum age a patient must be in order to visit this Provider.
    public let maxAge: Int?
    /// A specific brand that the `Provider` is associated with
    public let brand: String?
    /// Whether or not a `Provider` is currently active.
    public let isActive: Bool?
    
    /// A list of departments that a provider services in.
    public let departments: [ProviderDepartment]
    /// An array of `ProviderVisitTypes` that the provider supports
    public let visitTypes: [ProviderVisitType]
}
/// Represents a particular type of visit supported by a `Provider`
public struct ProviderVisitType: Codable, Equatable {
    /// A unique key for the visit type. This property will be used for filtering and queries
    public let visitTypeId: String
    /// The name of the Visit Type
    public let name: String
    /// The shortName of the Visit Type
    public let shortName: VisitTypeShortName?
    /// If available, more information about a Visit Type
    public let description: String?
    
    public init(
        visitTypeId: String, 
        name: String, 
        shortName: VisitTypeShortName?, 
        description: String?
    ) {
        self.visitTypeId = visitTypeId
        self.name = name
        self.shortName = shortName
        self.description = description
    }
}

/// A physical building that provides service of one or more health-care providers.
public struct ProviderDepartment: Codable {
    /// The unique key for this department
    public let departmentId: String
    /// The EHR System name for this department
    public let ehrSystemName: String
    /// The name of this department
    public let name: String
    
    // Optional properties
    /// If applicable, the medical center in which this department resides.
    public let center: String?
    /// If available, The phone number
    public let phone: String?
    /// The address if available.
    public let address: Address?
    
    enum CodingKeys: String, CodingKey {
        case departmentId
        case ehrSystemName = "epicInstanceName"
        case name
        case center
        case phone
        case address
    }
}
