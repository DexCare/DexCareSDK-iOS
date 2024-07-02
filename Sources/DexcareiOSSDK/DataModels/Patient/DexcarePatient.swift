// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// The base structure for a Dexcare Patient
public struct DexcarePatient: Codable, Equatable {
    /// A unique guid for a patient
    public let patientGuid: String
    /// A list of system identifiers for each EHR System that has a record for this patient
    internal var identifiers: [Identifier]
    /// A list of all Demographics that a Patient has. Each demographics will be associated to an EHR System.
    public let demographicsLinks: [PatientDemographics]
    /// Used internally to call PUT on patients
    internal var resourceType: String?
    
    enum CodingKeys: String, CodingKey {
        case patientGuid = "id"
        case identifiers
        case demographicsLinks = "links"
        case resourceType = "resourceType"
    }
}

extension DexcarePatient {
    internal init(patientGuid: String, demographicsLinks: [PatientDemographics]) {
        self.patientGuid = patientGuid
        self.identifiers = []
        self.demographicsLinks = demographicsLinks
    }
}

extension DexcarePatient {
    func demographics(from ehrSystemName: String) -> PatientDemographics? {
        return demographicsLinks.first { $0.ehrSystemName == ehrSystemName }
    }
}
