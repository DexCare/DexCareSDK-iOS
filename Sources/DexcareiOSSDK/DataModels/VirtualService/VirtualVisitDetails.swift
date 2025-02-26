import Foundation

// V9 Visit Details
// sourcery: AutoStubbable
/// An object containing additional information used to scheduled a virtual visit
public struct VirtualVisitDetails: Encodable, Equatable {
    /// Whether or not the patient has accepted the terms of use. Patients cannot schedule a virtual visit without accepting terms
    public var acceptedTerms: Bool

    /// Qualifications used to assign the visit to a provider. If a regular visit, or your environment does not support special assignment qualifiers, set to nil.
    public var assignmentQualifiers: [VirtualVisitAssignmentQualifier]?
    /// An enum used to determine who the visit should be scheduled for.
    public var patientDeclaration: PatientDeclaration
    /// A two-character state code, used to ensure the provider has a license to provide healthcare services to the patient.
    public var stateLicensure: String
    /// A short description describing the reason for scheduling the virtual visit.
    public var visitReason: String

    // sourcery: StubValue = "VirtualVisitTypeName.virtual"
    /// The type of virtual visit to schedule. See static properties on `VirtualVisitType` for the default supported values.
    public var visitTypeName: VirtualVisitTypeName

    // sourcery: StubValue = "useremail@domain.com"
    /// This should always be a non-empty email address which can be used to contact the app user.
    public var userEmail: String

    // sourcery: StubValue = "2042323232"
    /// This should always be a non-empty 10 digit phone number which can be used to contact the app user.
    public var contactPhoneNumber: String

    /// If not provided, default practice will be used
    public var practiceId: String?
    /// If the patient has done a pre-assessment, which tool was used.
    public var assessmentToolUsed: String?
    /// A brand for the visit. When not provided, a default is used.
    public var brand: String?

    /// Optional, language to request if interpreter services are available; ISO 639-3 Individual Language codes
    public var interpreterLanguage: String?

    /// An optional list of tags to be used in analytics when scheduling the visit.
    public var preTriageTags: [String]?

    /// An integer representing the urgency of the visit. 0 is default urgency, and as of Aug. 31, 2021, 1 and anything higher than 0 is marked as "high priority". This is open to be changed in the future.
    public var urgency: Int?

    /// This should always be filled in when booking a Virtual Visit for a dependent. When booking for self, this can be nil.
    public var actorRelationshipToPatient: RelationshipToPatient?

    /// Home market of the region, if applicable.
    public var homeMarket: String?

    // sourcery: StubValue = nil
    /// Sets the initial status of a virtual visit. If not set, ``VisitStatus.requested`` will be used.
    /// - Note: Some ``VisitStatus`` options may not be supported for initialStatus
    public var initialStatus: VisitStatus?

    /// Should the patient be considered traveling
    /// - Note: Your environment may not use this property. Leave nil otherwise.
    public var traveling: Bool?

    // sourcery: StubValue = nil
    /// Set internally by the SDK with the device language. Used in reports.
    var detectedLanguage: String? = Locale.current.identifier

    // sourcery: StubValue = nil
    /// Any additional meta data/information you wish to be saved with the visit.
    public var additionalDetails: AdditionalDetails?

    enum CodingKeys: String, CodingKey {
        case acceptedTerms
        case assignmentQualifiers
        case patientDeclaration = "declaration"
        case stateLicensure
        case visitReason
        case visitTypeName
        case practiceId
        case assessmentToolUsed
        case brand
        case interpreterLanguage
        case preTriageTags
        case urgency
        case actorRelationshipToPatient
        case initialStatus
        case detectedLanguage
        case traveling
    }

    // stub helper for adding in internal detectedLanguage
    init(acceptedTerms: Bool, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, patientDeclaration: PatientDeclaration, stateLicensure: String, visitReason: String, visitTypeName: VirtualVisitTypeName, userEmail: String, contactPhoneNumber: String, practiceId: String? = nil, assessmentToolUsed: String? = nil, brand: String? = nil, interpreterLanguage: String? = nil, preTriageTags: [String]? = nil, urgency: Int? = nil, actorRelationshipToPatient: RelationshipToPatient? = nil, homeMarket: String? = nil, initialStatus: VisitStatus? = nil, traveling: Bool? = nil, detectedLanguage: String? = nil, additionalDetails: AdditionalDetails? = nil) {
        self.init(acceptedTerms: acceptedTerms, assignmentQualifiers: assignmentQualifiers, patientDeclaration: patientDeclaration, stateLicensure: stateLicensure, visitReason: visitReason, visitTypeName: visitTypeName, userEmail: userEmail, contactPhoneNumber: contactPhoneNumber, practiceId: practiceId, assessmentToolUsed: assessmentToolUsed, brand: brand, interpreterLanguage: interpreterLanguage, preTriageTags: preTriageTags, urgency: urgency, actorRelationshipToPatient: actorRelationshipToPatient, homeMarket: homeMarket, initialStatus: initialStatus, traveling: traveling)

        self.detectedLanguage = detectedLanguage
    }

    public init(acceptedTerms: Bool, assignmentQualifiers: [VirtualVisitAssignmentQualifier]?, patientDeclaration: PatientDeclaration, stateLicensure: String, visitReason: String, visitTypeName: VirtualVisitTypeName, userEmail: String, contactPhoneNumber: String, practiceId: String? = nil, assessmentToolUsed: String? = nil, brand: String? = nil, interpreterLanguage: String? = nil, preTriageTags: [String]? = nil, urgency: Int? = nil, actorRelationshipToPatient: RelationshipToPatient? = nil, homeMarket: String? = nil, initialStatus: VisitStatus? = nil, traveling: Bool? = nil, additionalDetails: AdditionalDetails? = nil) {
        self.acceptedTerms = acceptedTerms
        self.assignmentQualifiers = assignmentQualifiers
        self.patientDeclaration = patientDeclaration
        self.stateLicensure = stateLicensure
        self.visitReason = visitReason
        self.visitTypeName = visitTypeName
        self.userEmail = userEmail
        self.contactPhoneNumber = contactPhoneNumber
        self.practiceId = practiceId
        self.assessmentToolUsed = assessmentToolUsed
        self.brand = brand
        self.interpreterLanguage = interpreterLanguage
        self.preTriageTags = preTriageTags
        self.urgency = urgency
        self.actorRelationshipToPatient = actorRelationshipToPatient
        self.homeMarket = homeMarket
        self.initialStatus = initialStatus
        self.traveling = traveling
        self.additionalDetails = additionalDetails
    }

    /// Function called internally to validate the `VirtualVisitDetails` that is passed in when starting a virtual visit.
    /// You can use this function to validate yourself before passing it up
    /// - Parameters:
    ///   - validateEmail: Skips the EmailValidator checks.
    /// - Throws: An error of type `String` indicating what is invalid
    public func validate(validateEmail: Bool) throws {
        if !acceptedTerms {
            throw "acceptedTerms must be true"
        }
        if let qualifiers = assignmentQualifiers, qualifiers.isEmpty {
            throw "assignmentQualifiers must not be empty, set to nil to use defaults"
        }

        if stateLicensure.isEmpty {
            throw "state licensure must not be empty"
        }

        if visitReason.isEmpty {
            throw "visitReason must not be empty"
        }

        if visitTypeName.rawValue.isEmpty {
            throw "visitTypeName must not be empty"
        }
        if patientDeclaration == .other && actorRelationshipToPatient == nil {
            throw "actorRelationshipToPatient must not be nil when patientDeclaration is other"
        }
        if userEmail.isEmpty {
            throw "userEmail must not be empty"
        }
        if validateEmail && !EmailValidator.isValid(email: userEmail) {
            throw "userEmail is not valid"
        }
        if contactPhoneNumber.isEmpty {
            throw "contactPhoneNumber must not be empty"
        }
        if !PhoneValidator.isValid(phoneNumber: PhoneValidator.removeNonDecimalCharacters(contactPhoneNumber)) {
            throw "contactPhoneNumber is invalid format"
        }
    }
}
