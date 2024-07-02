//
// PatientDeclaration.swift
// DexcareSDK
//
// Created by Barry on 4/23/20.
// Copyright © 2020 DexCare. All rights reserved.
//

import Foundation

/// Specifies who the patient will be for a visit
@frozen
public enum PatientDeclaration: String, Codable, Equatable {
    /// The current logged-in user
    case `self`
    /// someone other than the logged in user
    case other
}
