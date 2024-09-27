import CoreLocation
import Foundation

class LocationPermissionChecker: NSObject, LocationPermissionChecking {
    var locationManager: CLLocationManager?

    var callback: PermissionRequestCallback?

    func requestPermission() async -> RequestedPermissionStatus {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest // For currentNetwork info we need Precise location

        return await withCheckedContinuation { (continuation: CheckedContinuation<RequestedPermissionStatus, Never>) in
            checkStatusAndCallback { status in
                continuation.resume(returning: status)
            }
        }
    }

    func checkStatusAndCallback(completion: @escaping PermissionRequestCallback) {
        var status: CLAuthorizationStatus?
        if #available(iOS 14.0, *) {
            status = locationManager?.authorizationStatus
        } else {
            status = CLLocationManager.authorizationStatus()
        }

        switch status {
        case .notDetermined:
            callback = completion
            locationManager?.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            // Wifi Check needs to have full accuracy. If the user denies precise, the wifi check won't work.
            if #available(iOS 14.0, *) {
                var accuracy: CLAccuracyAuthorization?
                accuracy = locationManager?.accuracyAuthorization
                completion(accuracy == .fullAccuracy ? .granted : .denied)
            } else {
                completion(.granted)
            }
        case .denied:
            completion(.denied)
        case .restricted:
            completion(.denied)
        case .none:
            completion(.denied)
        @unknown default:
            completion(.denied)
        }
    }
}

extension LocationPermissionChecker: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if let callback = callback {
            checkStatusAndCallback(completion: callback)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let callback = callback {
            checkStatusAndCallback(completion: callback)
        }
    }
}
