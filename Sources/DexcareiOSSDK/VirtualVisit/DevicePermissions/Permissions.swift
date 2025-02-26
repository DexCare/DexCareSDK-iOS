// Copyright © 2019 DexCare. All rights reserved.

// sourcery: AutoStubbable
struct Permissions: Equatable {
    // sourcery: StubValue = .denied
    let camera: RequestedPermissionStatus

    // sourcery: StubValue = .denied
    let microphone: RequestedPermissionStatus

    // sourcery: StubValue = .denied
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

// sourcery: AutoMockable
protocol PermissionChecking {
    func requestPermission() async -> RequestedPermissionStatus
}

// sourcery: AutoMockable
protocol MicrophonePermissionChecking: PermissionChecking {}
// sourcery: AutoMockable
protocol VideoCameraPermissionChecking: PermissionChecking {}
// sourcery: AutoMockable
protocol NotificationPermissionChecking: PermissionChecking {}
