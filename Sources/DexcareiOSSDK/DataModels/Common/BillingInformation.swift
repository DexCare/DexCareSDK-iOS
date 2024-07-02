//
// BillingInformation.swift
// DexcareSDK
//
// Created by Barry on 4/22/20.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// Representing how a user will pay for their visit
public enum PaymentMethod: Equatable {
    /// Pay on arrival at retail clinic
    case `self`
    /// Payment with coupon code
    case couponCode(String)
    /// Payment with credit card
    /// - Parameters:
    ///    - stripeToken: a generated Stripe Token used for payment
    case creditCard(stripeToken: String)
    
    /// Payment by typing my own insurance information to form
    /// - Parameters:
    ///    - memberId: a user's unique id for their insurance provider
    ///    - payorId: a unique id representing the insurance provider. The supported list can be retrieved by calling `VirtualService.getInsurancePayers`
    ///    - insuranceGroupNumber: an optional parameter to include group numbers
    ///    - payorName: an optional parameter to include the Insurance Provider/Payor name. The supported list can be retrieved by calling `VirtualService.getInsurancePayers`
    case insuranceSelf(memberId: String, payorId: String, insuranceGroupNumber: String? = nil, payorName: String? = nil)
    
    /// Payment by typing someone else's insurance information into a form
    /// - Parameters:
    ///    - firstName: the given name of the insured person
    ///    - lastName: the family name of the insured person
    ///    - gender: the `Gender` of the insured person
    ///    - dateOfBirth: the birth date of the insured person
    ///    - memberId: the unique id of the insured person for their insurance provider
    ///    - payorId: a unique id representing the insurance provider. The supported list can be retrieved by calling `VirtualService.getInsurancePayers`
    ///    - insuranceGroupNumber: an optional parameter to include group number
    ///    - payorName: an optional parameter to include the Insurance Provider/Payor name. The supported list can be retrieved by calling `VirtualService.getInsurancePayers`
    ///    - subscriberId: an optional parameter when insurance providers require it
    case insuranceOther(firstName: String, lastName: String, gender: Gender, dateOfBirth: Date, memberId: String, payorId: String, insuranceGroupNumber: String? = nil, payorName: String? = nil, subscriberId: String? = nil)
}

/// An init which takes a PaymentInformation enum and fills in the correct BillingInformation fields
extension BillingInformation {
    init(paymentMethod: PaymentMethod) {
        switch paymentMethod {
        case .self:
            self = BillingInformation(
                paymentMethod: .self,
                paymentHolderDeclaration: nil // need this for compiler to disambiguate which init to use
            )
        case let .creditCard(stripeToken):
            self = BillingInformation(
                paymentMethod: .creditCard,
                stripeToken: stripeToken
            )
        case let .couponCode(couponCode):
            self = BillingInformation(
                paymentMethod: .couponCode,
                couponCode: couponCode
            )
        case let .insuranceSelf(memberId, payorId, insuranceGroupNumber, payorName):
            self = BillingInformation(
                paymentMethod: .insurance,
                paymentHolderDeclaration: .self,
                insuranceType: .manual,
                insuranceMemberId: memberId,
                insuranceGroupNumber: insuranceGroupNumber,
                insurancePayorId: payorId,
                insurancePayorName: payorName
            )
        case let .insuranceOther(firstName, lastName, gender, dateOfBirth, memberId, payorId, insuranceGroupNumber, payorName, subscriberId):
            self = BillingInformation(
                paymentMethod: .insurance,
                paymentHolderDeclaration: .other,
                firstName: firstName,
                lastName: lastName,
                gender: gender,
                dateOfBirth: dateOfBirth,
                insuranceType: .manual,
                insuranceMemberId: memberId,
                insuranceGroupNumber: insuranceGroupNumber,
                insurancePayorId: payorId,
                insurancePayorName: payorName,
                insuranceSubscriberId: subscriberId
            )
        }
    }
}

struct BillingInformation: Equatable {
    enum PaymentMethodInternal: String, Codable {
        case creditCard = "creditcard"
        case insurance = "insurance"
        case couponCode = "couponcode"
        case `self` = "self"
    }
    enum InsuranceType: String, Codable {
        /// manually entered into a form
        case manual = "manual"
        // "onfile" is supported on the server but not allowed from apps using the SDK at this time.
        // case onfile = "onfile"
        
    }
    
    /// Which form of payment will be used for this visit
    var paymentMethod: PaymentMethodInternal
    
    /// For insurance payment the payment holder (guarantor) can be the logged in user ("self") or someone else ("other").
    var paymentHolderDeclaration: PaymentHolderDeclaration?
    /// firstName required when paymentMethod != .creditCard
    var firstName: String?
    /// lastName required when paymentMethod = .insurance & paymentHolderDeclaration = other
    var lastName: String?
    /// gender required when paymentMethod = .insurance & paymentHolderDeclaration = other
    var gender: Gender?
    /// dateOfBirth required when paymentMethod = .insurance & paymentHolderDeclaration = other
    var dateOfBirth: Date?
    /// coupon code/service key when paymentMethod = .couponCode
    var couponCode: String?
    /// required when paymentMethod == .insurance
    var insuranceType: InsuranceType?
    /// required when paymentMethod == .insurance
    var insuranceMemberId: String?
    /// optional for paymentMethod= .insurance
    var insuranceGroupNumber: String?
    /// required when paymentMethod == .creditCard
    var stripeToken: String?
    /// required when paymentMethod == .insurance
    var insurancePayorId: String?
    /// an optional places to put the Insurance Payor Name
    var insurancePayorName: String?
    /// an optional places to put the subscriber id when using PaymentHolderDeclaration == .other
    var insuranceSubscriberId: String?
}

extension BillingInformation: Encodable {
    enum CodingKeys: String, CodingKey {
        case paymentMethod = "paymentMethod"
        case paymentHolderDeclaration = "declaration"
        case firstName = "firstName"
        case lastName = "lastName"
        case gender = "gender"
        case dateOfBirth = "dateOfBirth"
        case couponCode = "couponCode"
        case insuranceMemberId = "insuranceMemberId"
        case insuranceGroupNumber = "insuranceGroupNumber"
        case insuranceType = "insuranceType"
        case stripeToken = "stripeToken"
        case insurancePayorId = "insurancePayorId"
        case insuranceProviderId = "insuranceProviderId"
        case insurancePayorName = "insurancePayorName"
        case insuranceSubscriberId = "insuranceSubscriberId"
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(paymentMethod, forKey: CodingKeys.paymentMethod)
        
        if let birthdate = dateOfBirth {
            let birthdateString = DateFormatter.yearMonthDay.string(from: birthdate) // yyyy-dd-mm
            try container.encode(birthdateString, forKey: CodingKeys.dateOfBirth)
        }
        
        try container.encodeIfPresent(firstName, forKey: CodingKeys.firstName)
        try container.encodeIfPresent(lastName, forKey: CodingKeys.lastName)
        try container.encodeIfPresent(gender, forKey: CodingKeys.gender)
        try container.encodeIfPresent(paymentHolderDeclaration, forKey: CodingKeys.paymentHolderDeclaration)
        try container.encodeIfPresent(couponCode, forKey: CodingKeys.couponCode)
        try container.encodeIfPresent(insuranceMemberId, forKey: CodingKeys.insuranceMemberId)
        try container.encodeIfPresent(insuranceGroupNumber, forKey: CodingKeys.insuranceGroupNumber)
        try container.encodeIfPresent(insurancePayorId, forKey: CodingKeys.insurancePayorId)
        try container.encodeIfPresent(insurancePayorId, forKey: CodingKeys.insuranceProviderId)
        try container.encodeIfPresent(insurancePayorName, forKey: CodingKeys.insurancePayorName)
        try container.encodeIfPresent(insuranceSubscriberId, forKey: CodingKeys.insuranceSubscriberId)
        try container.encodeIfPresent(insuranceType, forKey: CodingKeys.insuranceType)
        try container.encodeIfPresent(stripeToken, forKey: CodingKeys.stripeToken)
    }
}
