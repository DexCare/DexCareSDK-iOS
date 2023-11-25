import Foundation
import UIKit

class TytoCareWifiPasswordViewController: UIViewController {
    weak var tytoCareManager: TytoCareManagerType?
    
    var togglePasswordButton: UIButton {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 25, height: 15))
        button.addTarget(self, action: #selector(togglePasswordHidden), for: .touchUpInside)
        button.setBackgroundImage(UIImage(named: "eye", in: .dexcareSDK, compatibleWith: nil), for: .normal)
        return button
    }
    
    @IBOutlet weak var wifiPasswordTextField: SkyFloatingLabelTextField! {
        didSet {
            wifiPasswordTextField.rightViewMode = .always
            wifiPasswordTextField.rightView = togglePasswordButton
        }
    }
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Connect to the Wi-Fi “\(tytoCareManager?.currentWifiName ?? "")”"
    }
    
    @objc func togglePasswordHidden() {
        wifiPasswordTextField.isSecureTextEntry.toggle()
    }
        
    @IBAction func nextButtonTapped() {
        tytoCareManager?.currentWifiPassword = wifiPasswordTextField.text
        tytoCareManager?.wifiInputComplete()
    }
    
    @IBAction func backTapped() {
        tytoCareManager?.goBack()
    }
    
}
