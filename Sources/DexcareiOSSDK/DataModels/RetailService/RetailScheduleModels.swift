// Copyright © 2019 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
struct ScheduleRetailAppointmentRequest: Encodable {
    let patient: Patient
    let actor: Actor?
    let visitDetails: VisitDetails
    let registrationModules: RegistrationModules

    // sourcery: AutoStubbable
    struct Patient: Encodable, Equatable {
        /// Patient GUID
        let identifier: String
        let address: Address
        let phone: String
        let email: String
    }

    // sourcery: AutoStubbable
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

    // sourcery: AutoStubbable
    struct RegistrationModules: Encodable, Equatable {
        let documentSigning: [DocumentSignature]

        struct DocumentSignature: Encodable, Equatable {
            let name: String
            let signed: Bool
        }

        // sourcery: StubValue = "BillingInformation(paymentMethod: .insuranceSelf(memberId: "MEMBER_ID", payorId: "PROVIDER_ID"))"
        let billingInfo: BillingInformation? // billingInfo is considered optional by the server even though the app requires it.
    }
}

// sourcery: AutoStubbable
struct ScheduleRetailAppointmentResponse: Codable {
    let visitId: String
}
