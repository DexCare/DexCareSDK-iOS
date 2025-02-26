//
// Actor.swift
// DexcareSDK
//
// Created by Barry on 4/22/20.
// Copyright © 2020 DexCare. All rights reserved.
//

// sourcery: AutoStubbable
struct Actor: Encodable, Equatable {
    var patientGuid: String?
    var firstName: String
    var lastName: String
    var phone: String
    var gender: Gender
    /// MM-dd-yyyy
    var dateOfBirth: String
    /// Father, Mother, etc. based on brand configuration
    var relationshipToPatient: RelationshipToPatient? // optional because its currently used for retail/provider only.

    init(
        patientGuid: String?,
        firstName: String,
        lastName: String,
        phone: String,
        gender: Gender,
        dateOfBirth: String,
        relationshipToPatient: RelationshipToPatient?
    ) {
        self.patientGuid = patientGuid
        self.firstName = firstName
        self.lastName = lastName
        self.phone = phone
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.relationshipToPatient = relationshipToPatient
    }
}
