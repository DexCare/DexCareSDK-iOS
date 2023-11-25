import Foundation
import UIKit

class TytoCareWifiNameViewController: UIViewController {
    weak var tytoCareManager: TytoCareManagerType?
    
    @IBOutlet weak var wifiNameTextField: SkyFloatingLabelTextField! {
        didSet {
            wifiNameTextField.delegate = self
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        wifiNameTextField.text = tytoCareManager?.currentWifiName
        updateNextButton()
    }
    
    func updateNextButton() {
        nextButton.isEnabled = !(wifiNameTextField.text ?? "").isEmpty
    }
    
    @IBAction func nextButtonTapped() {
        if !nextButton.isEnabled {
            return
        }
        tytoCareManager?.currentWifiName = wifiNameTextField.text
        tytoCareManager?.openWifiPasswordView(includeWifiNameView: false)
    }
    
    @IBAction func cancelTapped() {
        tytoCareManager?.closeView()
    }
}

extension TytoCareWifiNameViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 && string.count == 0 {
            nextButton.isEnabled = false
        } else {
            nextButton.isEnabled = true
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateNextButton()
    }
}
