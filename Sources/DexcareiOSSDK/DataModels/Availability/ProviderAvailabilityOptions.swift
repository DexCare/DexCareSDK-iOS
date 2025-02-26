// Copyright © 2022 DexCare. All rights reserved.//

import Foundation

// sourcery: AutoStubbable
/// Options when searching for provider availability - `AvailabilityService.getProviderAvailability`
public struct ProviderAvailabilityOptions: Encodable, Equatable {
    /// Health system defined visit type name filter.
    public var visitTypeNames: [String]?

    /// Start date of slots with yyyy-MM-dd format, default set to today if not present.
    public var startDate: Date?

    /// End date of slots with yyyy-MM-dd format, end days will be certain days after start date if not present.
    public var endDate: Date?

    /// Provider specialty filter
    public var specialty: String?

    /// Provider gender filter
    public var gender: Gender?

    /// EHR Instance Identifiers filter
    public var ehrInstances: [String]?

    /// Clinic type filter
    public var clinicType: [String]?

    /// How you want the results to be sorted
    /// - Note: defaults to ProviderAvailabilitySort.mostAvailable
    public var sortBy: ProviderAvailabilitySort?

    /// Can be used on `AvailabilityService.getProviderAvailabilitySlots` to rerun a previous search
    public var searchContext: String?

    public init(
        visitTypeNames: [String]? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        specialty: String? = nil,
        gender: Gender? = nil,
        ehrInstances: [String]? = nil,
        clinicType: [String]? = nil,
        sortBy: ProviderAvailabilitySort? = nil,
        searchContext: String? = nil
    ) {
        self.visitTypeNames = visitTypeNames
        self.startDate = startDate
        self.endDate = endDate
        self.specialty = specialty
        self.gender = gender
        self.ehrInstances = ehrInstances
        self.clinicType = clinicType
        self.sortBy = sortBy
        self.searchContext = searchContext
    }
}
