import Foundation
import UIKit

class TytoCareSetupViewController: UIViewController {
    weak var tytoCareManager: TytoCareManagerType?
    @IBOutlet weak var linkTextView: UITextView!
    @IBOutlet weak var messageDescription: UILabel! {
        didSet {
            messageDescription.text = localizeString("tytocare_message_description")
        }
    }

    @IBOutlet weak var setupButton: TytoCareStyleButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupHelpURL()
    }

    func setupHelpURL() {
        guard let helpURL = tytoCareManager?.helpURL else {
            linkTextView.isHidden = true
            return
        }
        linkTextView.isHidden = false
        let urlString = "For more information, visit: \n\(helpURL.absoluteString)"
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center

        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.label,
            NSAttributedString.Key.paragraphStyle: style,
        ]

        let attributedString = NSMutableAttributedString(string: urlString, attributes: attributes)

        let linkRange = (attributedString.string as NSString).range(of: helpURL.absoluteString)
        attributedString.addAttribute(NSAttributedString.Key.link, value: helpURL.absoluteString, range: linkRange)

        let textColor = UIColor(named: "tytoCareBlue", in: .dexcareSDK, compatibleWith: traitCollection)!
        let linkAttributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.foregroundColor: textColor,
            NSAttributedString.Key.underlineColor: textColor,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
        ]

        // textView is a UITextView
        linkTextView.linkTextAttributes = linkAttributes
        linkTextView.attributedText = attributedString
    }

    @IBAction func setupButtonTapped() {
        tytoCareManager?.checkForPermissions()
    }

    @IBAction func closeButtonTapped() {
        tytoCareManager?.closeView()
    }
}
