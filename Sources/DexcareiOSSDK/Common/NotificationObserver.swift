// Copyright © 2019 Providence. All rights reserved.

import Foundation

/// A helper class used in Notifications.
/// This wraps the userInfo property `value` so it can be used in generics
class UserInfoContainer<T> {
    let rawValue: T
    init(_ value: T) { self.rawValue = value }
}

class NotificationObserver {
    let observer: NSObjectProtocol
    
    init<T>(notification: NetworkNotification, block aBlock: @escaping (T) -> ()) {
        observer = NotificationCenter.default.addObserver(forName: notification.notificationName, object: nil, queue: nil) { note in
            if let value = (note.userInfo?["value"] as? UserInfoContainer<T>)?.rawValue {
                aBlock(value)
            } else {
                assert(false, "Couldn't understand user info")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(observer)
    }
}
