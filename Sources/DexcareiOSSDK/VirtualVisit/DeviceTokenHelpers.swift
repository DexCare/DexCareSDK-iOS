// Copyright © 2019 Providence. All rights reserved.

import Foundation
import UIKit

protocol PersistsDeviceToken {
    func persist(token: String)
    var persistedToken: String? { get }
    func removePersistedToken()
}

class TokenPersister: PersistsDeviceToken {
    
    private enum Constants {
        static let deviceKey = "TokenDeviceKey"
    }
    
    func persist(token: String) {
        UserDefaults.standard.set(token, forKey: Constants.deviceKey)
    }
    
    var persistedToken: String? {
        return UserDefaults.standard.string(forKey: Constants.deviceKey)
    }
    
    func removePersistedToken() {
        UserDefaults.standard.removeObject(forKey: Constants.deviceKey)
    }
}

protocol RemoteNotificationAppRegistering {
    func registerForRemoteNotifications()
}

extension UIApplication: RemoteNotificationAppRegistering {}
