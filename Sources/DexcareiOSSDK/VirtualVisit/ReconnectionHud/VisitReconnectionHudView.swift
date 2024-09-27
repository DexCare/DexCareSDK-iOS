// Copyright © 2018 DexCare. All rights reserved.

import Foundation
import UIKit

class VisitReconnectionHudView: UIView {
    enum Constants {
        static let cornerRadius: CGFloat = 18.0
        static let spinnerScale: CGFloat = 65.0 / 37.0 // Design size / large white spinner size
    }

    @IBOutlet private(set) weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet private(set) weak var reconnectionLabel: UILabel! {
        didSet {
            reconnectionLabel.text = localizeString("dialog_reconnect_title")
        }
    }

    @IBOutlet private(set) weak var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(localizeString("dialog_reconnect_cancel"), for: .normal)
        }
    }

    var didCancel: (() -> Void)?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadUIFromXib()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        loadUIFromXib()
    }

    func loadUIFromXib() {
        let xib = Bundle.dexcareSDK.loadNibNamed("VisitReconnectionHudView", owner: self, options: nil)
        guard let hudView = xib?.first as? UIView else {
            assertionFailure("Unable to load error message view")
            return
        }
        hudView.addAndClampToEdges(of: self)
        hudView.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 1000.0), for: .vertical)
        setupHudView()
    }

    func setupHudView() {
        // Add round corners
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = Constants.cornerRadius
        clipsToBounds = true
        // Scale spinner
        let transform = CGAffineTransform(scaleX: Constants.spinnerScale, y: Constants.spinnerScale)
        spinnerView.transform = transform
    }

    @IBAction func cancelHud(_ sender: Any) {
        didCancel?()
    }
}
