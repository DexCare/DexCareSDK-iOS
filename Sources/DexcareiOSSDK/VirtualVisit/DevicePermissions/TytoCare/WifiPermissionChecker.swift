import Foundation
import SystemConfiguration.CaptiveNetwork
import NetworkExtension

class WifiPermissionChecker: NSObject, WifiPermissionChecking {
    var currentWifiSSID: String?
    
    func requestPermission() async -> RequestedPermissionStatus {
        return await withCheckedContinuation({ (continuation: CheckedContinuation<RequestedPermissionStatus, Never>) in
            requestPermission { status in
                continuation.resume(returning: status)
            }
        })
    }
    
    func requestPermission(completion: @escaping PermissionRequestCallback) {
        
        if #available(iOS 14.0, *) {
            
            #if targetEnvironment(simulator)
            
            // fake simulator
            currentWifiSSID = "SIMULATOR"
            completion(.granted)
            
            #else
            
            NEHotspotNetwork.fetchCurrent { [weak self] network in
                guard let network = network else {
                    completion(.denied)
                    return
                }
                self?.currentWifiSSID = network.ssid
                completion(.granted)
            }
            
            #endif
        } else {
            #if targetEnvironment(simulator)
            // fake simulator
            currentWifiSSID = "SIMULATOR"
            completion(.granted)
            #else
            guard let interfaceNames = CNCopySupportedInterfaces() as? [String] else {
                completion(.denied)
                return
            }
            
            guard let name = interfaceNames.first, let info = CNCopyCurrentNetworkInfo(name as CFString) as? [String: Any] else {
                completion(.denied)
                return
            }
            
            guard let ssid = info[kCNNetworkInfoKeySSID as String] as? String else {
                completion(.denied)
                return
            }
            
            currentWifiSSID = ssid
            completion(.granted)

            #endif
        }
    }
}
