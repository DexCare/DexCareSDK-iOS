//
// Address.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2020-03-25.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// A generic structure of an address used in DexcareSDK
public struct Address: Codable, Equatable {
    /// 1st line of an address
    public var line1: String
    /// 2nd line of an address if one exists
    public var line2: String?
    /// City of the address
    public var city: String
    /// State of the address - usually in abbreviated form
    public var state: String
    /// Zip Code of the address - usually in 5 digit form
    public var postalCode: String
    
    public init(
        line1: String, 
        line2: String?, 
        city: String, 
        state: String, 
        postalCode: String
    ) {
        self.line1 = line1
        self.line2 = line2
        self.city = city
        self.state = state
        self.postalCode = postalCode
    }
}

extension Address {
    internal func validate() throws {
        if !ZipCodeValidator.isValid(zipCode: self.postalCode) {
            throw "invalid postal code"
        }
    }
}
