// Copyright © 2019 DexCare. All rights reserved.

struct Permissions: Equatable {
    let camera: RequestedPermissionStatus

    let microphone: RequestedPermissionStatus

    let notifications: RequestedPermissionStatus

    var granted: Bool {
        return camera == .granted && microphone == .granted // We shouldn't stop the user from entering a virtual visit if they deny notifications //&& notifications == .granted
    }
}

extension Permissions {
    var deniedPermissionType: VirtualVisitFailedReason.PermissionType {
        var result = VirtualVisitFailedReason.PermissionType(rawValue: 0)
        if camera == .denied {
            result.insert(.camera)
        }
        if microphone == .denied {
            result.insert(.microphone)
        }
        if notifications == .denied {
            result.insert(.notifications)
        }
        return result
    }
}

enum RequestedPermissionStatus: Equatable {
    case granted, denied
}

typealias PermissionRequestCallback = (RequestedPermissionStatus) -> Void

protocol PermissionChecking {
    func requestPermission() async -> RequestedPermissionStatus
}

protocol MicrophonePermissionChecking: PermissionChecking {}
protocol VideoCameraPermissionChecking: PermissionChecking {}
protocol NotificationPermissionChecking: PermissionChecking {}
