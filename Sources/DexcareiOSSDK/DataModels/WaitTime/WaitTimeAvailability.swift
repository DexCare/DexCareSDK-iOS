import Foundation

public struct WaitTimeAvailability: Decodable, Equatable {
    /// Date at UTC of when the estimated time was generated. Estimates are cached and updated at various intervals.
    public let generatedAt: Date
    /// Estimated wait time in seconds of the practice region, or when in the virtual visit waiting room.
    public let estimatedWaitTimeSeconds: Int?
    /// Message that is shown in the waiting room.
    public let estimatedWaitTimeMessage: String?
    /// Whether or not a region is available
    public let available: Bool
    /// An enum to describe the reason a Region is unavailable
    public let reason: Reason?
    /// A region code for wait time and availability. Typically a two-character string code
    public let regionCode: String
    /// A guid representing a Practice
    public let practiceId: String
    /// Visit types for waitTime and Availability
    public let visitTypeName: VirtualVisitTypeName
    /// Additional assignment qualifiers limiting this provider pool
    public let assignmentQualifiers: [VirtualVisitAssignmentQualifier]
    /// The home market for a patient
    public let homeMarket: String?
    
    /// Describes the reasons for a Region not being available
    public enum Reason: String, Codable {
        /// No regions have been set up
        case noRegionsFound = "NO_REGIONS_FOUND"
        /// The region is not currently open
        case offHours = "OFF_HOURS"
        @available(*, unavailable, renamed: "noOnCallProviders")
        case noOncallProviders = "old NO_ONCALL_PROVIDERS"
        /// No On Call Providers are available to have virtual visits
        case noOnCallProviders = "NO_ONCALL_PROVIDERS"
        /// The region is currently experiencing high demand
        case regionBusy = "REGION_BUSY"
        
        public init(from decoder: Decoder) throws {
            self = try WaitTimeAvailability.Reason(rawValue: decoder.singleValueContainer().decode(String.self)) ?? .noRegionsFound
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case generatedAt = "estimateGeneratedAt"
        case estimatedWaitTimeSeconds
        case estimatedWaitTimeMessage
        case available
        case reason
        case regionCode
        case practiceId
        case visitTypeName
        case assignmentQualifiers
        case homeMarket
    }
    
    /// An internal decoder to handle dates.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.estimatedWaitTimeSeconds = try? values.decodeIfPresent(Int.self, forKey: CodingKeys.estimatedWaitTimeSeconds)
        self.estimatedWaitTimeMessage = try? values.decodeIfPresent(String.self, forKey: CodingKeys.estimatedWaitTimeMessage)
        self.available = try values.decode(Bool.self, forKey: CodingKeys.available)
        self.reason = try? values.decodeIfPresent(Reason.self, forKey: CodingKeys.reason)
        self.regionCode = try values.decode(String.self, forKey: CodingKeys.regionCode)
        self.practiceId = try values.decode(String.self, forKey: CodingKeys.practiceId)
        
        let visitTypeNameString = try values.decode(String.self, forKey: CodingKeys.visitTypeName)
        self.visitTypeName = VirtualVisitTypeName(rawValue: visitTypeNameString)
        
        let assignmentQualifierString = try values.decode([String].self, forKey: CodingKeys.assignmentQualifiers)
        self.assignmentQualifiers = assignmentQualifierString.map { VirtualVisitAssignmentQualifier(rawValue: $0) }
        self.homeMarket = try? values.decodeIfPresent(String.self, forKey: CodingKeys.homeMarket)
        
        let generatedAtString = try values.decode(String.self, forKey: CodingKeys.generatedAt)
        if let generatedAt = DateFormatter.iso8601Full.date(from: generatedAtString) {
            self.generatedAt = generatedAt
        } else {
            throw "Invalid generatedAt format"
        }
    }
}
