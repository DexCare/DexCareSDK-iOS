// Copyright © 2020 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
/// A structure containing information about a patient's name
public struct HumanName: Codable, Equatable {
    /// Family name (often call surname or last name)
    public var family: String
    /// Given name (often called first name)
    public var given: String
    /// Middle name if any
    public var middle: String?
    /// Parts that come before the name
    public var prefix: String?
    /// Parts that come after the name
    public var suffix: String?
    /// String defining FHIR NameUse - eg usual | official | temp | nickname | anonymous | old | maiden
    public var use: String?

    public init(
        family: String,
        given: String,
        middle: String?,
        prefix: String?,
        suffix: String?,
        use: String?
    ) {
        self.family = family
        self.given = given
        self.middle = middle
        self.prefix = prefix
        self.suffix = suffix
        self.use = use
    }
}

extension HumanName {
    var display: String {
        return given + " " + family
    }
}
