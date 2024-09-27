// Copyright © 2019 DexCare. All rights reserved.

import Foundation

// Based on https://github.com/providenceinnovation/visit-service/blob/master/app/api/Liontower.VisitService.v6.yaml

/// Specifies who is paying for the visit.
@frozen
public enum PaymentHolderDeclaration: String {
    /// The current logged-in user
    case `self`
    /// someone other than the logged in user
    case other
}

extension PaymentHolderDeclaration: Codable {}

struct ScheduleVirtualVisitResponse: Decodable, Equatable {
    let visitId: String?
    // There are lots of other fields but most we don't need until we call /visit/{visitId} which
    // returns much of the same data
}

struct TokBoxVisit: Decodable, Equatable {
    let apiKey: String? // API key required for joining tokbox session
    let waitingRoomSession: TokBoxSession
    let videoConferenceSession: TokBoxSession
}

struct TokBoxSession: Decodable, Equatable {
    let sessionId: String
}
