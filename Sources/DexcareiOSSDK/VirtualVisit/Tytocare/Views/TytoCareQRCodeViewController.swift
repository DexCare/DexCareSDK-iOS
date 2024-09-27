import Foundation
import UIKit

class TytoCareQRCodeViewController: UIViewController {
    weak var tytoCareManager: TytoCareManagerType?

    @IBOutlet weak var qrCodeImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        generateQRCode()
    }

    func generateQRCode() {
        if let qrImage = tytoCareManager?.generateQRCodeImage() {
            qrCodeImageView.image = qrImage
        }
    }

    @IBAction func generateNewCodeTapped() {
        // restarts the process
        tytoCareManager?.checkForPermissions()
    }

    @IBAction func closeTapped() {
        tytoCareManager?.closeView()
    }
}
