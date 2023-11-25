// Copyright © 2021 Providence. All rights reserved.

import Foundation

/// Response for ProviderService.getMaxLookaheadDays. Internal
internal struct MaxLookaheadDayResponse: Codable {
    let maxLookaheadDays: Int
}
