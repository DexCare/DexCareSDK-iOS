// Copyright © 2019 Providence. All rights reserved.

import Foundation

protocol BearerTokenAware {
    var authenticationToken: String { get set }
}

// MARK: - Refresh Token Notification
/// A Dexcare.Notification type that is used to notify services of when a token has refreshed.
let refreshTokenNotification: NetworkNotification = NetworkNotification()
