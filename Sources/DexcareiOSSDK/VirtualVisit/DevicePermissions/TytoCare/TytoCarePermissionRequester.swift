import Foundation

// sourcery: AutoStubbable
struct TytoCarePermissions: Equatable {
    // sourcery: StubValue = .denied
    let location: RequestedPermissionStatus

    // sourcery: StubValue = .denied
    let wifi: RequestedPermissionStatus
}

// sourcery: AutoMockable
protocol LocationPermissionChecking: PermissionChecking {}
// sourcery: AutoMockable
protocol WifiPermissionChecking: PermissionChecking {
    var currentWifiSSID: String? { get }
}

// sourcery: AutoMockable
protocol TytoCarePermissionService {
    var currentWifiSSID: String? { get }

    func requestPermissions() async -> TytoCarePermissions
}

class TytoCarePermissionRequester: TytoCarePermissionService {
    lazy var locationChecker: LocationPermissionChecking = LocationPermissionChecker()
    lazy var wifiChecker: WifiPermissionChecking = WifiPermissionChecker()

    var currentWifiSSID: String? {
        return wifiChecker.currentWifiSSID
    }

    func requestPermissions() async -> TytoCarePermissions {
        let locationPermissionStatus = await locationChecker.requestPermission()

        // without proper location, we won't even have a chance to get wifi name
        if locationPermissionStatus == .denied {
            let permission = TytoCarePermissions(location: locationPermissionStatus, wifi: .denied)
            return permission
        }

        let wifiStatus = await wifiChecker.requestPermission()
        let permission = TytoCarePermissions(location: locationPermissionStatus, wifi: wifiStatus)
        return permission
    }
}
