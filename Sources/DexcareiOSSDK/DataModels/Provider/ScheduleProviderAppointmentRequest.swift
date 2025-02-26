// Copyright © 2021 DexCare. All rights reserved.

import Foundation

// sourcery: AutoStubbable
struct ScheduleProviderAppointmentRequest: Encodable {
    let patient: Patient
    let actor: Actor?
    let visitDetails: VisitDetails
    // sourcery: StubValue = "BillingInformation(paymentMethod: .insuranceSelf(memberId: "MEMBER_ID", payorId: "PROVIDER_ID"))"
    let billingInfo: BillingInformation

    // sourcery: AutoStubbable
    struct Patient: Encodable, Equatable {
        /// Patient GUID
        let patientGuid: String
        let address: Address
    }

    // sourcery: AutoStubbable
    struct VisitDetails: Encodable, Equatable {
        let ehrSystemName: String
        let departmentId: String
        let visitReason: String
        let declaration: PatientDeclaration
        let slotId: String // base64 encoded data from the the time slot object returned from the /departments/{departmentId/timeSlots} call
        let nationalProviderId: String
        let visitTypeId: String
        let patientQuestions: [PatientQuestion]?
        let providerFlowPayment: Bool
    }
}
