import Foundation

/// When searching for Provider Availability - responses will return with `ProviderAvailabilityResult` object
public struct ProviderAvailabilityResult: Codable {
    // MARK: Properties

    /// Array of `ProviderAvailability` returned for the search
    public var results: [ProviderAvailability]
}
