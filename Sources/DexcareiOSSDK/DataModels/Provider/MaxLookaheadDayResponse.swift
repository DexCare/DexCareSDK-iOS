// Copyright © 2021 DexCare. All rights reserved.

import Foundation

/// Response for ProviderService.getMaxLookaheadDays. Internal
internal struct MaxLookaheadDayResponse: Codable {
    let maxLookaheadDays: Int
}
