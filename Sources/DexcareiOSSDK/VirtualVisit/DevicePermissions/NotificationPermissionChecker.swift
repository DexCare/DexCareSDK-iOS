// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import UserNotifications

class NotificationPermissionChecker: NotificationPermissionChecking {
    func requestPermission() async -> RequestedPermissionStatus {
        return await withCheckedContinuation { (continuation: CheckedContinuation<RequestedPermissionStatus, Never>) in
            let alertOptions: UNAuthorizationOptions = [.alert, .sound, .badge]

            UNUserNotificationCenter.current().requestAuthorization(options: alertOptions) { granted, _ in
                continuation.resume(returning: granted ? .granted : .denied)
            }
        }
    }
}
