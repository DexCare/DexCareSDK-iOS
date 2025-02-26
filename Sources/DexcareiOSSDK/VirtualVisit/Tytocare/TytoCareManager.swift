import Foundation
import UIKit

protocol TytoCareManagerType: AnyObject {
    var currentWifiName: String? { get set }
    var currentWifiPassword: String? { get set }
    var helpURL: URL? { get }

    func checkForPermissions()
    func closeView()
    func goBack()

    func openTytoCare(from parent: UIViewController)
    func openWifiNameView()
    func openWifiPasswordView(includeWifiNameView: Bool)
    func wifiInputComplete()
    func openDeviceSettings()

    func generateQRCodeImage() -> UIImage?
}

/// Failure Reasons during the TytoCare integration setup
public enum TytoCareFailedReason: Error {
    /// When setting up a TytoCare device, the user has denied a location (full precision) or wifi network has failed.
    /// - Note: This doesn't stop the user from manually setting up the wifi network
    case permissionDenied(type: TytoCarePermissionType)
    /// When pairing the device the DexCare account is a minor.
    case underAge
    /// A generic error when the other enums aren't caught
    case failed(error: Error)

    public struct TytoCarePermissionType: OptionSet {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }

        public static let location = TytoCarePermissionType(rawValue: 1 << 0)
        public static let wifi = TytoCarePermissionType(rawValue: 1 << 1)
    }
}

class TytoCareManager: NSObject, TytoCareManagerType {
    lazy var tytoCarePermissionService: TytoCarePermissionService = TytoCarePermissionRequester()

    weak var virtualService: InternalVirtualService?

    var visitId: String?
    var tytoCareConfig: TytoCareConfig?
    var logger: DexcareSDKLogger?

    var navigator: TytoCareNavigatorType?
    var currentWifiName: String?
    var currentWifiPassword: String?
    var pairingDetails: String?

    var helpURL: URL? {
        return tytoCareConfig?.helpURL
    }

    init(visitId: String, tytoCareConfig: TytoCareConfig, logger: DexcareSDKLogger?, virtualService: InternalVirtualService?) {
        super.init()

        self.visitId = visitId
        self.tytoCareConfig = tytoCareConfig
        self.logger = logger
        self.virtualService = virtualService
    }

    func checkForPermissions() {
        Task {
            let permissions = await tytoCarePermissionService.requestPermissions()

            currentWifiName = tytoCarePermissionService.currentWifiSSID
            logger?.log("Location Permission: \(permissions.location == .granted ? " ✅ GRANTED" : " ❌ DENIED")")
            logger?.log("Wifi Permission: \(permissions.wifi == .granted ? " ✅ GRANTED - SSID: \(currentWifiName != nil ? "****" : "N/A")" : " ❌ DENIED")")

            // permission not granted for location - show permissions view
            if permissions.location != .granted {
                openPermissionView()
                return
            }

            if currentWifiName == nil {
                openWifiNameView()
            } else {
                // this allows the WifiName view to be pushed in the stack, but basically skipped, so if the user goes back, allowing them to edit the WifiName if need be
                openWifiPasswordView(includeWifiNameView: true)
            }
        }
    }

    func openTytoCare(from parent: UIViewController) {
        navigator = TytoCareNavigator(presentingViewController: parent, manager: self)
        navigator?.showTytoCareSetup()
    }

    func openPermissionView() {
        navigator?.showPermissionView()
    }

    func openWifiNameView() {
        navigator?.showWifiNameView()
    }

    func openWifiPasswordView(includeWifiNameView: Bool) {
        navigator?.showWifiPasswordView(includeWifiNameView: includeWifiNameView)
    }

    func wifiInputComplete() {
        guard let visitId = visitId else {
            logger?.log("Visit Id is not set in TytoCareManager", level: .error)
            return
        }
        navigator?.showHud()
        Task {
            do {
                let pairDetails = try await virtualService?.pairDevice(visitId: visitId)
                DispatchQueue.main.async { [weak self] in
                    self?.pairingDetails = pairDetails
                    self?.navigator?.hideHud()
                    self?.navigator?.showQRCodeView()
                }
            } catch {
                DispatchQueue.main.async { [weak self] in
                    self?.navigator?.hideHud()
                    self?.logger?.log("Error Pairing TytoCare Device: \(String(describing: error))", level: .error)

                    if let error = error as? TytoCareFailedReason {
                        self?.virtualService?.virtualEventDelegate?.onVirtualVisitError(error: .devicePairError(.tytoCarePairFailed(error)))
                        if case .underAge = error {
                            self?.showUnder18Alert()
                        } else {
                            self?.showErrorAlert()
                        }
                    } else {
                        self?.virtualService?.virtualEventDelegate?.onVirtualVisitError(error: .devicePairError(.tytoCarePairFailed(.failed(error: error))))
                    }
                }
            }
        }
    }

    func showErrorAlert() {
        navigator?.displayAlert(title: "Unexpected Error", message: "There was an error processing your device pairing request. Please check your network connection and try again.", actions: [
            VirtualVisitAlertAction(title: localizeString("dialog.button.ok"), style: .cancel, handler: nil),
        ])
    }

    func showUnder18Alert() {
        navigator?.displayAlert(title: "Unable to create TytoCare account", message: "You must be 18 years or older to create a TytoCare account.", actions: [
            VirtualVisitAlertAction(title: localizeString("dialog.button.ok"), style: .cancel, handler: nil),
        ])
    }

    func getQRCodeString(date: Date? = Date()) -> String? {
        guard let pairingDetails else {
            logger?.log("No pairingDetails Set", level: .error)
            return nil
        }

        guard let wifiName = currentWifiName else {
            logger?.log("Wifi name is nil when generating QR Code", level: .error)
            return nil
        }

        guard let wifiPassword = currentWifiPassword else {
            logger?.log("Wifi password is nil when generating QR Code", level: .error)
            return nil
        }

        guard let ssidEncoded = wifiName.data(using: .utf8) else {
            logger?.log("Could not encode WifiName when generating QR Code", level: .error)
            return nil
        }
        let date = date ?? Date()
        let utcDate = String(describing: Int(date.timeIntervalSince1970))
        let ssidEncodeString = ssidEncoded.base64EncodedString()

        let qrCodeString = [
            ":V4:", // A
            "\(String(wifiPassword.count))::", // B + C
            "0:", // D
            ",,,", // E + F + G
            "\(String(wifiName.lengthOfBytes(using: .utf8))),", // H
            "\(wifiName + wifiPassword),", // I
            "\(utcDate),", // J
            "\(String(ssidEncodeString.lengthOfBytes(using: .utf8))),", // K
            "\(ssidEncodeString),", // L
            "\(pairingDetails),", // M
            "vExternal",
        ].joined(separator: "")

        return qrCodeString
    }

    func generateQRCodeImage() -> UIImage? {
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }

        guard let qrCodeString = getQRCodeString() else { return nil }

        #if DEBUG
            print("QR: \(qrCodeString)")
        #endif

        let qrData = qrCodeString.data(using: String.Encoding.ascii)
        qrFilter.setValue(qrData, forKey: "inputMessage")

        let qrTransform = CGAffineTransform(scaleX: 12, y: 12)
        guard let qrImage = qrFilter.outputImage?.transformed(by: qrTransform) else {
            return nil
        }

        // both dark mode and light mode will have a black front, and white back.
        // Tried with a variety of inverted, but the device hard a hard time scanning in dark mode.
        let colorParameters = [
            "inputColor0": CIColor(color: UIColor.black), // Foreground
            "inputColor1": CIColor(color: UIColor.white), // Background
        ]

        let colored = qrImage.applyingFilter("CIFalseColor", parameters: colorParameters)
        return UIImage(ciImage: colored)
    }

    func closeView() {
        navigator?.closeView()
    }

    func goBack() {
        navigator?.goBack(animated: true)
    }

    func openDeviceSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
