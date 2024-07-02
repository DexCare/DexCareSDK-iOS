// Copyright © 2019 DexCare. All rights reserved.

import Foundation

struct VisitSummary: Decodable, Equatable {
    let visitId: String
    let practiceId: String
    let userId: String
    let status: VisitStatus
    let tokBoxVisit: TokBoxVisit?
    let tytoCare: TytoCareResponse
    
    // v9
    let modality: VirtualVisitModality? // should be not optional on v9 visits. But if looking up old visits, will be null
    
    enum CodingKeys: String, CodingKey {
        case visitId
        case practiceId
        case userId
        case status
        case isTokBox
        case tokBoxVisit
        case integrations
        case tytoCare
        case modality
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
         
        visitId = try container.decode(String.self, forKey: .visitId)
        practiceId = try container.decode(String.self, forKey: .practiceId)
        userId = try container.decode(String.self, forKey: .userId)
        status = try container.decode(VisitStatus.self, forKey: .status)
        tokBoxVisit = try? container.decode(TokBoxVisit.self, forKey: .tokBoxVisit)
        
        let integrationContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .integrations)
        tytoCare = try integrationContainer.decode(TytoCareResponse.self, forKey: .tytoCare)
        
        // v9
        if let modalityString = try? container.decode(String.self, forKey: .modality) {
            modality = VirtualVisitModality(rawValue: modalityString)
        } else {
            modality = nil
        }
    }

    init(
        visitId: String,
        practiceId: String,
        userId: String,
        status: VisitStatus,
        tokBoxVisit: TokBoxVisit?,
        tytoCare: TytoCareResponse,
        modality: VirtualVisitModality?
    ) {
        self.visitId = visitId
        self.practiceId = practiceId
        self.userId = userId
        self.status = status
        self.tokBoxVisit = tokBoxVisit
        self.tytoCare = tytoCare
        self.modality = modality
    }
}

/// A status of a Virtual Visit
/// A `RawRepresentable` structure representing the status a visit could have
/// - Note: A `VisitStatus` in this context is simply a `String`. You can exchange a `VisitStatus` with a string without issue.
///
public struct VisitStatus: RawRepresentable, Codable, Equatable {
    public typealias RawValue = String
    public var rawValue: String
    
    /// visit has been requested
    public static let requested = VisitStatus(rawValue: "requested")
    /// visit is in the waiting room
    public static let waitingRoom = VisitStatus(rawValue: "waitingroom")
    
    @available(*, unavailable, renamed: "waitingRoom")
    public static let waitingroom = VisitStatus(rawValue: "old waitingroom")
    
    /// visit is currently in a virtual visit
    public static let inVisit = VisitStatus(rawValue: "invisit")
    @available(*, unavailable, renamed: "inVisit")
    public static let invisit = VisitStatus(rawValue: "old invisit")
    /// visit has completed
    public static let done = VisitStatus(rawValue: "done")
    /// visit was cancelled
    public static let cancelled = VisitStatus(rawValue: "cancelled")
    /// visit was declined by the staff before seeing a provider
    public static let staffDeclined = VisitStatus(rawValue: "staffdeclined")
    @available(*, unavailable, renamed: "staffDeclined")
    public static let staffdeclined = VisitStatus(rawValue: "old staffdeclined")
    
    /// The patient is waiting offline for a notification before rejoining the visit
    public static let waitOffline = VisitStatus(rawValue: "waitoffline")
    
    /// A caregiver is already assigned and is ready to start a visit immediately
    public static let caregiverAssigned = VisitStatus(rawValue: "caregiverassigned")
    
    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
    
    /// A helper function to tell you whether or not a visit is classified as expired.
    /// - Note: When this is true, you must start a new virtual visit and cannot resume.
    public func isActive() -> Bool {
        switch self {
        case VisitStatus.done, VisitStatus.cancelled, VisitStatus.staffDeclined:
            return false
        case VisitStatus.caregiverAssigned, VisitStatus.requested, VisitStatus.inVisit, VisitStatus.waitingRoom, VisitStatus.waitOffline:
            return true
        default:
            return true
        }
    }
}

struct TokBoxTokenResponse: Decodable, Equatable {
    let token: String
}

struct TytoCareResponse: Decodable, Equatable {
    let enabled: Bool
}
