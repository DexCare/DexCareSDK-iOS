// Copyright © 2019 Providence. All rights reserved.

import Foundation

extension String: Error {}

struct CancelRetailAppointmentRequestNew: Codable {
    var reason: String
}

enum ResourceType: String, Codable {
    case appointment = "Appointment"
    
    init(from decoder: Decoder) throws {
        self = try ResourceType(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .appointment
    }
}

enum ReferenceType: String, Codable {
    case organization = "Organization"
    case practitioner = "Practitioner"
    case healthCareService = "HealthCareService"
    case patient = "Patient"
    case unknown = "Unknown"
    
    init(from decoder: Decoder) throws {
        self = try ReferenceType(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .unknown
    }
}
