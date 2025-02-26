//
// ProviderVisitInformation.swift
// DexcareSDK
//
// Created by Matt Kiazyk on 2021-01-18.
// Copyright © 2021 DexCare. All rights reserved.
//

import Foundation

// sourcery: AutoStubbable
/// Contains additional information required to book a Provider visit.
public struct ProviderVisitInformation: Equatable, Codable {
    /// A short description describing the reason for scheduling the provider visit.
    public var visitReason: String
    /// An enum used to determine who the visit should be scheduled for.
    public var patientDeclaration: PatientDeclaration
    // sourcery: StubValue = "auserEmail@domain.com"
    /// This should always be a non-empty email address which can be used to contact the app user.
    /// - Note: the patient email address as returned by Epic is not guaranteed to be present. For this reason, it is recommended to always collect this information from an alternative source, e.g. Auth0 email.
    public var userEmail: String

    // sourcery: StubValue = "2398432323"
    /// This should always be a non-empty 10 digit phone number which can be used to contact the app user.
    public var contactPhoneNumber: String

    /// Set and used internally by the SDK.
    public var nationalProviderId: String

    /// Set and used internally by the SDK.
    public var visitTypeId: String

    /// Set and used internally by the SDK.
    public var ehrSystemName: String

    // sourcery: StubValue = nil
    /// This should always be filled in when booking a Visit for a dependent. When booking for self, this can be nil.
    public let actorRelationshipToPatient: RelationshipToPatient?

    // sourcery: StubValue = nil
    /// A generic Question + answer
    public var patientQuestions: [PatientQuestion]?

    public init(
        visitReason: String,
        patientDeclaration: PatientDeclaration,
        userEmail: String,
        contactPhoneNumber: String,
        nationalProviderId: String,
        visitTypeId: String,
        ehrSystemName: String,
        actorRelationshipToPatient: RelationshipToPatient?,
        patientQuestions: [PatientQuestion]? = nil
    ) {
        self.visitReason = visitReason
        self.patientDeclaration = patientDeclaration
        self.userEmail = userEmail
        self.contactPhoneNumber = contactPhoneNumber
        self.nationalProviderId = nationalProviderId
        self.visitTypeId = visitTypeId
        self.ehrSystemName = ehrSystemName
        self.actorRelationshipToPatient = actorRelationshipToPatient
        self.patientQuestions = patientQuestions
    }
}
