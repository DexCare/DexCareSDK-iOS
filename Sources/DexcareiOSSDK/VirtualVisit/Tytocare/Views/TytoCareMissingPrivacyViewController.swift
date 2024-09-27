import Foundation
import UIKit

class TytoCareMissingPrivacyViewController: UIViewController {
    weak var tytoCareManager: TytoCareManagerType?

    @IBAction func networkButtonTapped() {
        tytoCareManager?.openDeviceSettings()
    }

    @IBAction func manualButtonTapped() {
        tytoCareManager?.openWifiNameView()
    }
}
