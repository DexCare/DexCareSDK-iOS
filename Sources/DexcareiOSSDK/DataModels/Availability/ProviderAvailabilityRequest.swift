//
// ProviderAvailabilityRequest.swift
// DexcareiOSSDK
//
// Created by Matt Kiazyk on 2022-09-26.
// Copyright © 2022 DexCare. All rights reserved.
//

import Foundation

struct ProviderAvailabilityRequest: Codable, Equatable {
    /// Health system defined visit type name filter.
    var visitTypeNames: [String]?

    /// Department identifier filter.
    /// DepartmentID's or Lat/Lng or Zip are required
    var departmentIds: [String]?

    /// Latitude of target visit location
    var latitude: Double?

    /// Longitude of target visit location
    var longitude: Double?

    /// PostalCode code of the target visit location (zip code)
    /// Note: Either use postalCode or longitude/latitude for location based searching not both.
    var postalCode: String?

    /// Radius around target visit location in miles
    /// Note: Minimum is 1, Maximum is 100
    var radius: Int?

    /// Start date of slots with yyyy-MM-dd format, default set to today if not present.
    var startDate: Date?

    /// End date of slots with yyyy-MM-dd format, end days will be certain days after start date if not present.
    var endDate: Date?

    /// Provider specialty filter
    var specialty: String?

    /// Provider gender filter
    var gender: Gender?

    /// EHR Instance Identifiers filter
    var ehrInstances: [String]?

    /// ClinicType filter
    var clinicType: [String]?

    /// How you want the results to be sorted by
    /// Note: defaults to ProviderAvailabilitySort.mostAvailable
    var sortBy: ProviderAvailabilitySort?

    var searchContext: String?
}

extension ProviderAvailabilityRequest {
    /// checks for validity and returns the appropriate missing info
    func isValid(forSlots isForSlots: Bool = false) throws {
        try departmentIds?.forEach {
            if $0.isEmpty {
                throw "DepartmentId can not be empty"
            }
        }

        if latitude == 0 {
            throw "Latitude can not be 0"
        }

        if longitude == 0 {
            throw "Longitude can not be 0"
        }

        if let postalCode = postalCode, postalCode.isEmpty {
            throw "zipCode can not be empty"
        }
        if isForSlots {
            // VisitTypeNames are required for availability/slots
            guard visitTypeNames != nil else {
                throw "visitTypeNames are required"
            }
        }

        try visitTypeNames?.forEach {
            if $0.isEmpty {
                throw "VisitTypeName can not be empty"
            }
        }
    }
}

extension ProviderAvailabilityRequest {
    init(departmentIds: [String], options: ProviderAvailabilityOptions?) throws {
        if departmentIds.count == 0 {
            throw FailedReason.missingInformation(message: "Missing DepartmentIds")
        }
        self.departmentIds = departmentIds

        self.visitTypeNames = options?.visitTypeNames
        self.startDate = options?.startDate
        self.endDate = options?.endDate
        self.specialty = options?.specialty
        self.gender = options?.gender
        self.ehrInstances = options?.ehrInstances
        self.clinicType = options?.clinicType
        self.sortBy = options?.sortBy
    }

    init(latitude: Double, longitude: Double, radius: Int?, options: ProviderAvailabilityOptions?) throws {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius

        self.visitTypeNames = options?.visitTypeNames
        self.startDate = options?.startDate
        self.endDate = options?.endDate
        self.specialty = options?.specialty
        self.gender = options?.gender
        self.ehrInstances = options?.ehrInstances
        self.clinicType = options?.clinicType
        self.sortBy = options?.sortBy
    }

    init(postalCode: String, radius: Int?, options: ProviderAvailabilityOptions?) throws {
        self.postalCode = postalCode
        self.radius = radius

        self.visitTypeNames = options?.visitTypeNames
        self.startDate = options?.startDate
        self.endDate = options?.endDate
        self.specialty = options?.specialty
        self.gender = options?.gender
        self.ehrInstances = options?.ehrInstances
        self.clinicType = options?.clinicType
        self.sortBy = options?.sortBy
    }
}
