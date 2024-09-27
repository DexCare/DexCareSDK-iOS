// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// The basic information about a patient is stored in PatientDemographics
public struct PatientDemographics: Codable, Equatable {
    /// Information about the patient name
    public var name: HumanName
    /// Addresses of the patient.
    public var addresses: [Address]
    /// The patient's birthdate
    /// - Important: birthdate will be converted to a string with GMT:0 when pushed to the server
    /// Therefore it's important that any `Date` object that gets set here, must be set with a timezone of GMT:0 .
    public var birthdate: Date
    /// The email saved with the demographic
    public var email: String
    /// male, female, other
    public var gender: Gender
    /// ehrSystemName is automatically broken out with the first Identifier. When setting use ehrSystemName
    public let identifiers: [Identifier]
    /// Which EHR System is used to save the data into Epic
    public var ehrSystemName: String?
    /// last 4 digits of ssn
    public var last4SSN: String
    /// A optional home phone number if exits
    public var homePhone: String?

    /// A mobile phone number if available
    public var mobilePhone: String?
    /// A work phone number if available
    public var workPhone: String?

    enum CodingKeys: String, CodingKey {
        case name
        case addresses
        case birthdate
        case email
        case gender
        case identifiers
        case last4SSN = "ssn"
        case homePhone
        case mobilePhone
        case workPhone
    }

    // Initializer used only for stubbing tests
    init(
        name: HumanName,
        addresses: [Address],
        birthdate: Date,
        email: String,
        gender: Gender,
        identifiers: [Identifier],
        ehrSystemName: String?,
        last4SSN: String,
        homePhone: String?,
        mobilePhone: String?,
        workPhone: String?
    ) {
        self.name = name
        self.addresses = addresses
        self.birthdate = birthdate
        self.email = email
        self.gender = gender
        self.identifiers = identifiers
        self.ehrSystemName = ehrSystemName
        self.last4SSN = last4SSN
        self.homePhone = homePhone
        self.mobilePhone = mobilePhone
        self.workPhone = workPhone
    }

    public init(name: HumanName, addresses: [Address], birthdate: Date, email: String, gender: Gender, ehrSystemName: String?, last4SSN: String, homePhone: String?, mobilePhone: String?, workPhone: String?) {
        self.name = name
        self.addresses = addresses
        self.birthdate = birthdate
        self.email = email
        self.gender = gender
        self.ehrSystemName = ehrSystemName
        self.last4SSN = last4SSN
        self.homePhone = homePhone
        self.mobilePhone = mobilePhone
        self.workPhone = workPhone
        if let ehrSystemName = ehrSystemName {
            self.identifiers = [Identifier(systemName: ehrSystemName)]
        } else {
            self.identifiers = []
        }
    }

    /// a custom decoder used internally by DexcareSDK
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try values.decode(HumanName.self, forKey: CodingKeys.name)
        self.addresses = try values.decode([Address].self, forKey: CodingKeys.addresses)
        let birthdateString = try values.decode(String.self, forKey: CodingKeys.birthdate)
        if let birthdate = DateFormatter.yearMonthDay.date(from: birthdateString) {
            self.birthdate = birthdate
        } else {
            throw "Invalid birthdate format"
        }
        self.email = try values.decode(String.self, forKey: CodingKeys.email)
        self.gender = try values.decode(Gender.self, forKey: CodingKeys.gender)

        let identifiersDecode = try values.decode([Identifier].self, forKey: CodingKeys.identifiers)
        self.identifiers = identifiersDecode
        self.ehrSystemName = identifiersDecode.first?.system

        self.last4SSN = try values.decode(String.self, forKey: CodingKeys.last4SSN)
        self.homePhone = try? values.decode(String.self, forKey: CodingKeys.homePhone)
        self.mobilePhone = try? values.decode(String.self, forKey: CodingKeys.mobilePhone)
        self.workPhone = try? values.decode(String.self, forKey: CodingKeys.workPhone)
    }

    /// a custom encoder used internally by DexcareSDK
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(name, forKey: CodingKeys.name)
        try container.encode(addresses, forKey: CodingKeys.addresses)
        try container.encode(DateFormatter.yearMonthDay.string(from: birthdate), forKey: CodingKeys.birthdate)
        try container.encode(email, forKey: CodingKeys.email)
        try container.encode(gender, forKey: CodingKeys.gender)
        try container.encode(last4SSN, forKey: CodingKeys.last4SSN)
        if let homePhone = homePhone {
            try? container.encode(homePhone, forKey: CodingKeys.homePhone)
        }
        if let mobilePhone = mobilePhone {
            try? container.encode(mobilePhone, forKey: CodingKeys.mobilePhone)
        }
        if let workPhone = workPhone {
            try? container.encode(workPhone, forKey: CodingKeys.workPhone)
        }

        guard let ehrSystemName = ehrSystemName else {
            throw ("ehrSystemName is missing")
        }

        let identifier = [Identifier(systemName: ehrSystemName)]
        try container.encode(identifier, forKey: CodingKeys.identifiers)
    }
}

extension PatientDemographics {
    func validate() throws {
        if let homePhone = homePhone, !homePhone.isEmpty, !PhoneValidator.isValid(phoneNumber: homePhone) {
            throw "Invalid home phone number"
        }
        if let mobile = mobilePhone, !mobile.isEmpty, !PhoneValidator.isValid(phoneNumber: mobile) {
            throw "Invalid mobile phone number"
        }

        if let work = workPhone, !work.isEmpty, !PhoneValidator.isValid(phoneNumber: work) {
            throw "Invalid work phone number"
        }

        if self.birthdate > Date() {
            throw "birthdate must not be in the future"
        }
        if addresses.isEmpty {
            throw "missing address"
        }

        try addresses.forEach { address in
            try address.validate()
        }
    }
}
