import Foundation

/// A structure representing the status of the DexCare Services.
public struct DexcareStatus: Codable {
    /// The name of the customer that is associated with the status
    public let name: String
    /// The current indicator of the status
    public let impact: IncidentImpact
    /// A short description of the current Dexcare status - `Minor Service Outage`, `All Systems Operational` are some examples that would be returned
    public let description: String
    /// Last date time the status was updated
    public let updatedAt: Date

    /// An array of `DexcareIncident` that are currently active
    public let incidents: [DexcareIncident]
    /// An array of `DexcareIncident` that are currently scheduled
    public let scheduledMaintenances: [DexcareIncident]

    enum CodingKeys: String, CodingKey {
        case name
        case impact = "indicator"
        case description
        case updatedAt = "updated_at"
        case incidents
        case scheduledMaintenances = "scheduled_maintenances"
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let dateString = try values.decode(String.self, forKey: CodingKeys.updatedAt)
        // We're reusing Schedule Day for Retail and Providers
        // Both endpoints come back with different date formats
        if let dateTime = DateFormatter.iso8601.date(from: dateString) {
            self.updatedAt = dateTime
        } else {
            throw "Invalid date format for DexcareStatus.updatedAt"
        }

        self.name = try values.decode(String.self, forKey: CodingKeys.name)
        self.impact = try values.decode(IncidentImpact.self, forKey: CodingKeys.impact)
        self.description = try values.decode(String.self, forKey: CodingKeys.description)
        self.incidents = try values.decode([DexcareIncident].self, forKey: CodingKeys.incidents)
        self.scheduledMaintenances = try values.decode([DexcareIncident].self, forKey: CodingKeys.scheduledMaintenances)
    }
}

/// A structure representing an incident or a scheduled maintenance
public struct DexcareIncident: Codable {
    /// A small description of the incident or maintenance
    public let name: String
    /// A larger description describing the incident. This is optional and may not be included on all responses
    public let body: String?
    /// A status of the current incident - See `IncidentStatus` for more information
    public let status: IncidentStatus
    /// The impact of the current incident - See `IncidentImpact` for more information
    public let impact: IncidentImpact
    /// The last date time updated.
    public let updatedAt: Date
    /// The date time at which a maintenance is scheduled to start. Only present for maintenances.
    public let scheduledFor: Date?
    /// The date time at which a maintenance is scheduled to end. Only present for maintenances.
    public let scheduledUntil: Date?
    /// The individual parts of the DexCare Platform that this incident is affecting.
    public let components: [DexcareComponent]

    enum CodingKeys: String, CodingKey {
        case name
        case body
        case status
        case impact
        case updatedAt = "updated_at"
        case scheduledFor = "scheduled_for"
        case scheduledUntil = "scheduled_until"
        case components
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.name = try values.decode(String.self, forKey: CodingKeys.name)
        self.body = try values.decodeIfPresent(String.self, forKey: CodingKeys.body)
        self.status = try values.decode(IncidentStatus.self, forKey: CodingKeys.status)
        self.impact = try values.decode(IncidentImpact.self, forKey: CodingKeys.impact)
        self.components = try values.decode([DexcareComponent].self, forKey: CodingKeys.components)

        let dateString = try values.decode(String.self, forKey: CodingKeys.updatedAt)
        if let dateTime = DateFormatter.iso8601.date(from: dateString) {
            self.updatedAt = dateTime
        } else {
            throw "Invalid date format for DexcareIncident.updatedAt"
        }

        if let dateString = try values.decodeIfPresent(String.self, forKey: CodingKeys.scheduledFor) {
            if let dateTime = DateFormatter.iso8601.date(from: dateString) {
                self.scheduledFor = dateTime
            } else {
                throw "Invalid date format for DexcareIncident.scheduledFor"
            }
        } else {
            self.scheduledFor = nil
        }

        if let dateString = try values.decodeIfPresent(String.self, forKey: CodingKeys.scheduledUntil) {
            if let dateTime = DateFormatter.iso8601.date(from: dateString) {
                self.scheduledUntil = dateTime
            } else {
                throw "Invalid date format for DexcareIncident.scheduledUntil"
            }
        } else {
            self.scheduledUntil = nil
        }
    }
}

/// The various stages of progress towards resolution that a `DexcareIncident` could be at.
public enum IncidentStatus: String, Codable {
    /// The incident is being looked at by DexCare engineers.
    case investigating
    /// The issue has been identified and a fix is being implemented.
    case identified
    /// The fix has been implemented and the situation is being watched to ensure resolution.
    case monitoring
    /// The issue has been fully resolved and is no longer being monitored.
    case resolved
    /// A maintenance is planned but has not yet started.
    case scheduled
    /// A maintenance window has started.
    case inProgress = "in_progress"
    /// A potential fix has been found and is currently being validated.
    case verifying
    /// The maintenance window has concluded.
    case completed
    /// Only returned if the enum value could not be parsed to one of the above.
    case unknown = ""
}

/// The degree at which a `DexcareIncident`]` affects a DexCare platform or component.
public enum IncidentImpact: String, Codable {
    /// The DexCare platform or component is experiencing a extreme disruption.
    case critical
    /// The DexCare platform or component is currently unavailable due to a planned maintenance.
    case maintenance
    /// The DexCare platform or component is not affected.
    case none
    /// The DexCare platform or component is experiencing a large disruption.
    case major
    /// The DexCare platform or component is experiencing a small disruption.
    case minor
}

/// A structure representing a component of a DexCare service
public struct DexcareComponent: Codable {
    // not sure if we need this yet. Depending how how status page is grouped, this can be used to get a status of a group of components
    let groupId: String?

    /// The name of the component. ie. `Acme Express Care - Retail`
    public let name: String
    /// The status of of the component. During an incident or a scheduled maintenance, this will be updated. Regular operations, these will be set to `DexcareComponentStatus.operational`
    public let status: DexcareComponentStatus
    /// The type of DexCare service component. See `DexcareComponentType` for a list of components
    public let type: DexcareComponentType

    enum CodingKeys: String, CodingKey {
        case name
        case groupId = "group_id"
        case status
        case type
    }
}

/// An enum representing the DexCare service component. During incidents and scheduled maintenances, multiple components may be effected
public enum DexcareComponentType: String, Codable {
    /// The connection to Epic and Interconnect
    case epic
    /// Virtual visits (see `PracticeService` and `VirtualService`)
    case virtual
    /// Retail, in-person visits (see `RetailService`)
    case retail
    /// Direct-to-provider visits (see `ProviderService`)
    case providerBooking = "provider_booking"
    /// The web portal that caregivers use to connect to virtual visits.
    case providerPortal = "caregiver_portal"
    /// The third-party service used for video conferencing during virtual visits.
    case tokbox
    /// Only returned if the enum value could not be parsed to one of the above.
    case unknown = ""
}

/// An enum representing a status of a component. During regular operations, this will be `operational`
public enum DexcareComponentStatus: String, Codable {
    /// The issue has been fully resolved.
    case resolved
    /// The maintenance window has concluded.
    case completed
    /// The component is working without issues.
    case operational
    /// A maintenance is planned but has not yet started.
    case scheduled
    /// The component is undergoing a scheduled maintenance and is currently unavailable.
    case underMaintenance = "under_maintenance"
    /// An issue is affecting the component, and the component may not be fully functional.
    case degradedPerformance = "degraded_performance"
    /// An issue is affecting the component, and the component is not fully functional.
    case partialOutage = "partial_outage"
    /// An issue is affecting the component, and the component is non-functional.
    case majorOutage = "major_outage"
    /// Only returned if the enum value could not be parsed to one of the above.
    case unknown = ""
}
