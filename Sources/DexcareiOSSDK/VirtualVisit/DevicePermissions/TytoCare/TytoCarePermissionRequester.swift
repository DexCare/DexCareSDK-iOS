import Foundation

struct TytoCarePermissions: Equatable {
    
    let location: RequestedPermissionStatus
    
    let wifi: RequestedPermissionStatus
}

protocol LocationPermissionChecking: PermissionChecking { }
protocol WifiPermissionChecking: PermissionChecking {
    var currentWifiSSID: String? { get }
}

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
