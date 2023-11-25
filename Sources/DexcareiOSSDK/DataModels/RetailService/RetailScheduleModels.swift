// Copyright © 2019 Providence. All rights reserved.

import Foundation

struct ScheduleRetailAppointmentRequest: Encodable {
    let patient: Patient
    let actor: Actor?
    let visitDetails: VisitDetails
    let registrationModules: RegistrationModules
    
    struct Patient: Encodable, Equatable {
        /// Patient GUID
        let identifier: String
        let address: Address
        let phone: String
        let email: String
    }
    
    struct VisitDetails: Encodable, Equatable {
        let ehrSystemName: String
        let departmentId: String
        let visitReason: String
        let declaration: PatientDeclaration
        let slotId: String // base64 encoded data from the the time slot object returned from the /departments/{departmentId/timeSlots} call
        /// non-national ID for provider
        let providerId: String
        let patientQuestions: [PatientQuestion]?
    }
    
    struct RegistrationModules: Encodable, Equatable {
        let documentSigning: [DocumentSignature]

        struct DocumentSignature: Encodable, Equatable {
            let name: String
            let signed: Bool
        }
        
        let billingInfo: BillingInformation? // billingInfo is considered optional by the server even though the app requires it.
    }
}

struct ScheduleRetailAppointmentResponse: Codable {
    let visitId: String
}
