// Copyright © 2018 DexCare. All rights reserved.

import Foundation

protocol DevicePermissionService {
    func requestPermissions(withVisitType visitType: VirtualVisitTypeName) async -> Permissions
}

class DevicePermissionRequester: DevicePermissionService {
    lazy var microphoneChecker: MicrophonePermissionChecking = MicrophonePermissionChecker()
    lazy var cameraChecker: VideoCameraPermissionChecking = VideoCameraPermissionChecker()
    lazy var notificationChecker: NotificationPermissionChecking = NotificationPermissionChecker()

    func requestPermissions(withVisitType visitType: VirtualVisitTypeName) async -> Permissions {
        #if DEBUG
            if UnitTestDetector.isRunningIntegrationTests() {
                let permissions = Permissions(camera: .granted, microphone: .granted, notifications: .granted)
                return permissions
            }
        #endif
        // only really care about notifications for phone
        if visitType == .phone {
            let notificationStatus = await notificationChecker.requestPermission()

            let permissions = Permissions(camera: .granted, microphone: .granted, notifications: notificationStatus)
            return permissions
        } else {
            let microphoneStatus = await microphoneChecker.requestPermission()
            let cameraStatus = await cameraChecker.requestPermission()
            let notificationStatus = await notificationChecker.requestPermission()

            let permissions = Permissions(camera: cameraStatus, microphone: microphoneStatus, notifications: notificationStatus)
            return permissions
        }
    }
}

class UnitTestDetector {
    static func isRunningIntegrationTests() -> Bool {
        return ProcessInfo.processInfo.arguments.contains("isRunningIntegrationTests")
    }
}
