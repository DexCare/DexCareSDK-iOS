import Foundation
import UIKit

protocol ShadowableRoundableView {
    var cornerRadius: CGFloat { get set }
    var shadowColor: UIColor { get set }
    var shadowOffsetWidth: CGFloat { get set }
    var shadowOffsetHeight: CGFloat { get set }
    var shadowOpacity: Float { get set }
    var shadowRadius: CGFloat { get set }

    var shadowLayer: CAShapeLayer { get }

    func setCornerRadiusAndShadow()
}

extension ShadowableRoundableView where Self: UIView {
    func setCornerRadiusAndShadow() {
        layer.cornerRadius = cornerRadius
        shadowLayer.path = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: cornerRadius
        ).cgPath
        shadowLayer.fillColor = backgroundColor?.cgColor
        shadowLayer.shadowColor = shadowColor.cgColor
        shadowLayer.shadowPath = shadowLayer.path
        shadowLayer.shadowOffset = CGSize(
            width: shadowOffsetWidth,
            height: shadowOffsetHeight
        )
        shadowLayer.shadowOpacity = shadowOpacity
        shadowLayer.shadowRadius = shadowRadius
    }
}

enum TytoCareButtonState {
    case open
    case closed
}

// Bird Button
@IBDesignable
class TytoCareButton: UIButton, ShadowableRoundableView {
    enum Constants: String, RawRepresentable {
        typealias RawValue = String

        case buttonTitle = "Pair device"
    }

//    var manager: TytoCareManagerType?
    var buttonState: TytoCareButtonState = .open {
        didSet {
            updateButtonState()
        }
    }

    var widthConstraint: NSLayoutConstraint?

    @IBInspectable var cornerRadius: CGFloat = 4 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var shadowColor: UIColor = .darkGray {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var shadowOffsetWidth: CGFloat = 2 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var shadowOffsetHeight: CGFloat = 3 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var shadowOpacity: Float = 0.25 {
        didSet {
            self.setNeedsLayout()
        }
    }

    @IBInspectable var shadowRadius: CGFloat = 4 {
        didSet {
            self.setNeedsLayout()
        }
    }

    private(set) lazy var shadowLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        self.layer.insertSublayer(layer, at: 0)
        self.setNeedsLayout()
        return layer
    }()

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setCornerRadiusAndShadow()
    }

    func updateButtonState() {
        switch self.buttonState {
        case .open:
            self.setTitle(Constants.buttonTitle.rawValue, for: .normal)
            self.widthConstraint?.constant = 144
            self.imageEdgeInsets.left = 20
        case .closed:
            self.setTitle("", for: .normal)
            self.widthConstraint?.constant = 54
            self.imageEdgeInsets.left = 14
        }
        // having trouble animating and making it look nice.. so not doing it ATM.

        setNeedsUpdateConstraints()
        layoutIfNeeded()
    }

    func setupButton() {
        let imageAsset = UIImage(named: "tytoCareBird", in: .dexcareSDK, compatibleWith: traitCollection)
        self.setImage(imageAsset, for: .normal)
    }
}
