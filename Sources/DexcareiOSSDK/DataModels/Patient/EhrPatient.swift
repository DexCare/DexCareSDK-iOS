import Foundation

// converts an Old DexcarePatient so we can use it as the new `EhrPatient`
extension DexcarePatient {
    /// A helper method to create a `VirtualPatient` given a patientGuid and a `PatientDemographics`
    /// - Note: If any of the information in the provided `PatientDemographics` object is missing or invalid this function will throw an error with what is missing.
    /// - Parameters:
    ///  - patientGuid: Can be retrieved from a `DexcarePatient` after calling `PatientService.findOrCreatePatient` or `PatientService.findOrCreateDependentPatient`
    ///  - patientDemographics: The particular set of `PatientDemographics` used to populate this model with. SDK will check the `PatientDemographics.homePhone` for phone first, `PatientDemographics.mobilePhone` second, and `PatientDemographics.workPhone` last. The SDK will use the first `PatientDemographics.address`
    /// - Throws: A string error representing what value did not pass validation. ex: Missing address
    /// - Note: The SDK will check homePhone, mobilePhone, workPhone in that order. If none of those properties are set, function will throw
    static func createDexcareVirtualPatient(patientGuid: String, patientDemographics: PatientDemographics, relationshipToPatient: RelationshipToPatient? = nil) throws -> EhrPatient {
        var phone: String?

        if let homePhone = patientDemographics.homePhone {
            phone = homePhone
        } else if let mobilePhone = patientDemographics.mobilePhone {
            phone = mobilePhone
        } else if let workPhone = patientDemographics.workPhone {
            phone = workPhone
        }

        guard let phone = phone else {
            throw "Missing homePhone, mobilePhone or workPhone"
        }
        guard let address = patientDemographics.addresses.first else {
            throw "Missing address"
        }
        return EhrPatient(
            firstName: patientDemographics.name.given,
            lastName: patientDemographics.name.family,
            gender: patientDemographics.gender,
            dateOfBirth: patientDemographics.birthdate,
            phone: phone,
            email: patientDemographics.email,
            address: address,
            patientGuid: patientGuid,
            relationshipToPatient: relationshipToPatient,
            ehrIdentifier: nil,
            ehrIdentifierType: nil,
            homeEhr: nil,
            homeMarket: nil
        )
    }
}

/// The base structure for an EHR Patient
public struct EhrPatient: Codable, Equatable {
    /// First name of patient (often called Given Name)
    public var firstName: String
    /// Last name of patient (often call surname or family name)
    public var lastName: String
    /// male, female, other
    public var gender: Gender
    /// The patient's date of birth
    /// - Important: dateOfBirth will be converted to a string with GMT:0 when pushed to the server
    /// Therefore it's important that any `Date` object that gets set here, must be set with a timezone of GMT:0 .
    public var dateOfBirth: Date
    /// A phone number which the patient can be contact with
    public var phone: String
    /// The patients email address
    public var email: String
    /// Address of the patient
    public var address: Address

    // for DexcarePatients - internally we are using this to make a single "Patient"
    var patientGuid: String?
    // internal as we are reusing EHRPatient for Actors on V9 Visit Requests
    var relationshipToPatient: RelationshipToPatient?

    // for EHR Patients
    /// An identifier of the patient record in Epic.
    public var ehrIdentifier: String?
    /// The type of identifier being sent in [ehrIdentifier], e.g. "MRN" or "EPI".
    public var ehrIdentifierType: String?
    /// Home EHR code
    public var homeEhr: String?

    // Internal because we are asking clients to fill in through VirtualVisitDetails, as it's irrelevant to Patients, but the api is requiring it through patient property
    /// Home market, if applicable.
    var homeMarket: String?

    public init(
        firstName: String,
        lastName: String,
        gender: Gender,
        dateOfBirth: Date,
        phone: String,
        email: String,
        address: Address,
        ehrIdentifier: String?,
        ehrIdentifierType: String?,
        homeEhr: String?,
        homeMarket: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.phone = phone
        self.email = email
        self.address = address
        self.patientGuid = nil
        self.relationshipToPatient = nil
        self.ehrIdentifier = ehrIdentifier
        self.ehrIdentifierType = ehrIdentifierType
        self.homeEhr = homeEhr
        self.homeMarket = homeMarket
    }

    // internal so we can reuse VirtualPatient for both DexcarePatient and EhrPatient
    init(
        firstName: String,
        lastName: String,
        gender: Gender,
        dateOfBirth: Date,
        phone: String,
        email: String,
        address: Address,
        patientGuid: String?,
        relationshipToPatient: RelationshipToPatient? = nil,
        ehrIdentifier: String?,
        ehrIdentifierType: String?,
        homeEhr: String?,
        homeMarket: String?
    ) {
        self.firstName = firstName
        self.lastName = lastName
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.phone = phone
        self.email = email
        self.address = address
        self.patientGuid = patientGuid
        self.relationshipToPatient = relationshipToPatient
        self.ehrIdentifier = ehrIdentifier
        self.ehrIdentifierType = ehrIdentifierType
        self.homeEhr = homeEhr
        self.homeMarket = homeMarket
    }

    /// A helper method used internally by the SDK to perform minimal validation on the `VirtualPatient` before sending it to the server.
    /// This method checks the following in order:
    /// - firstName is not empty
    /// - lastName is not empty
    /// - phone is not empty
    /// - phone is valid per `PhoneValidator.isValid` The phone number is stripped of any special characters before validation.
    /// - Unless skipped with validateEmail parameter, email is not empty and is valid per `EmailValidator.isValid`
    /// - address.postalCode is validate per `ZipCodeValidator.isValid`
    /// - Throws: A string representing what value did not pass validation
    func validate() throws {
        if firstName.isEmpty {
            throw "firstName must not be empty"
        }

        if lastName.isEmpty {
            throw "lastName must not be empty"
        }

        if phone.isEmpty {
            throw "phone must not be empty"
        }

        if email.isEmpty {
            throw "email must not be empty"
        }

        try address.validate()

        if (patientGuid ?? "").isEmpty {
            if (ehrIdentifier ?? "").isEmpty {
                throw "ehrIdentifier must not be empty"
            }
            if (ehrIdentifierType ?? "").isEmpty {
                throw "ehrIdentifierType must not be empty"
            }
            if (homeEhr ?? "").isEmpty {
                throw "homeEhr must not be empty"
            }
            if let homeMarket = homeMarket, homeMarket.isEmpty {
                throw "homeMarket must not be empty if setting. Set to nil if not available"
            }
        }
    }

    /// Internal Helper function to display identifiers of patient.
    var identifiers: [String: String] {
        return ["PatientGuid": patientGuid ?? "", "EHRIdentifierType": ehrIdentifierType ?? "", "EHRIdentifier": ehrIdentifier ?? "", "homeEHR": homeEhr ?? "", "homeMarket": homeMarket ?? ""]
    }

    var displayName: String {
        return firstName + " " + lastName
    }

    enum CodingKeys: String, CodingKey {
        case firstName
        case lastName
        case dateOfBirth
        case email
        case gender
        case phone
        case address
        case ehrIdentifier
        case ehrIdentifierType
        case homeEhr
        case homeMarket
        case patientGuid
        case relationshipToPatient
    }

    /// a custom encoder used internally by DexcareSDK
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(firstName, forKey: CodingKeys.firstName)
        try container.encode(lastName, forKey: CodingKeys.lastName)
        try container.encode(DateFormatter.yearMonthDay.string(from: dateOfBirth), forKey: CodingKeys.dateOfBirth)
        try container.encode(email, forKey: CodingKeys.email)
        try container.encode(gender, forKey: CodingKeys.gender)
        try container.encode(phone, forKey: CodingKeys.phone)
        try container.encode(email, forKey: CodingKeys.email)
        try container.encode(address, forKey: CodingKeys.address)

        try container.encodeIfPresent(ehrIdentifier, forKey: CodingKeys.ehrIdentifier)
        try container.encodeIfPresent(ehrIdentifierType, forKey: CodingKeys.ehrIdentifierType)
        try container.encodeIfPresent(homeEhr, forKey: CodingKeys.homeEhr)
        try container.encodeIfPresent(homeMarket, forKey: CodingKeys.homeMarket)
        try container.encodeIfPresent(patientGuid, forKey: CodingKeys.patientGuid)
        try container.encodeIfPresent(relationshipToPatient, forKey: CodingKeys.relationshipToPatient)
    }
}
