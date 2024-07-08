// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import UIKit

protocol VisitView: AnyObject {
    var manager: VirtualVisitManagerType? { get set }
    var tytoCareManager: TytoCareManagerType? { get set }
    
    var enabledRemoteCamera: Bool { get set }
    var micButtonImage: UIImage? { get set }
    var cameraButtonImage: UIImage? { get set }
    
    var showCameraPositionToggle: Bool { get set }
    
    func addLocalView(_ view: UIView, resolutionSize: CGSize)
    func addRemoteView(_ view: UIView, resolutionSize: CGSize)
    func removeLocalView()
    func removeRemoteView()
}

class VisitViewController: UIViewController, VisitView {
    weak var manager: VirtualVisitManagerType?
    weak var tytoCareManager: TytoCareManagerType? {
        didSet {
            setupTytoCare()
        }
    }
    
    @IBOutlet weak var localViewContainer: UIView!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var remoteView: UIView!
    @IBOutlet weak var remoteVideoDisabledLabel: UILabel!
    @IBOutlet weak var hangupButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var positionButton: UIButton!
    @IBOutlet weak var localViewButton: UIButton!
    @IBOutlet weak var remoteWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var localWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var localViewContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var tytoWidthConstraint: NSLayoutConstraint! {
        didSet {
            tytoCareButton.widthConstraint = tytoWidthConstraint
        }
    }
    @IBOutlet weak private(set) var tytoCareButton: TytoCareButton!
    
    private enum Images {
        static var expanded = UIImage(named: "ic_call_received_white", in: .dexcareSDK, compatibleWith: nil)!
        static let collapsed: UIImage = UIImage(cgImage: expanded.cgImage!, scale: 1.0, orientation: .down)
    }
    
    private enum Constants {
        static var animationDuration = 0.25
        static var localViewWidth: CGFloat = 90.0
    }
    
    var enabledRemoteCamera: Bool = true {
        didSet {
            remoteVideoDisabledLabel.isHidden = enabledRemoteCamera
            remoteView.isHidden = !enabledRemoteCamera
        }
    }
    
    var micButtonImage: UIImage? {
        didSet {
            micButton.setImage(micButtonImage, for: .normal)
        }
    }
    
    var cameraButtonImage: UIImage? {
        didSet {
            cameraButton.setImage(cameraButtonImage, for: .normal)
        }
    }
    
    var showCameraPositionToggle: Bool = false {
        didSet {
            positionButton.isHidden = !showCameraPositionToggle
        }
    }
    
    @IBAction func localViewButtonTapped(_ sender: Any) {
        if localViewContainerWidthConstraint.constant == 0.0 {
            self.localViewButton.setImage(Images.expanded, for: .normal)
            self.localViewContainerWidthConstraint.constant = Constants.localViewWidth
            UIView.animate(withDuration: Constants.animationDuration) {
                self.view.layoutIfNeeded()
            }
        } else {
            self.localViewContainerWidthConstraint.constant = 0.0
            self.localViewButton.setImage(Images.collapsed, for: .normal)
            UIView.animate(withDuration: Constants.animationDuration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    @IBAction func hangupButtonTapped(_ sender: Any) {
        manager?.hangup()
    }
    
    @IBAction func micButtonTapped(_ sender: Any) {
        manager?.toggleMic()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        manager?.toggleCamera()
    }
    
    @IBAction func chatButtonTapped(_ sender: Any) {
        manager?.openChat()
    }
    
    @IBAction func positionButtonTapped(_ sender: Any) {
        manager?.toggleCameraPosition()
    }
    
    @IBAction func tytocareButtonTapped() {
        tytoCareManager?.openTytoCare(from: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        enabledRemoteCamera = true
        
        micButton.backgroundColor = .buttonColor
        cameraButton.backgroundColor = .buttonColor
        chatButton.backgroundColor = .buttonColor
        
        setupTytoCare()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    func addLocalView(_ view: UIView, resolutionSize: CGSize) {
        view.addAndClampToEdges(of: localView)
        resizeStream(size: resolutionSize, containerHeight: localViewContainer.bounds.height, widthConstraint: localWidthConstraint)
    }
    
    func addRemoteView(_ view: UIView, resolutionSize: CGSize) {
        view.addAndClampToEdges(of: remoteView)
        resizeStream(size: resolutionSize, containerHeight: view.bounds.height, widthConstraint: remoteWidthConstraint)
    }
    
    func removeLocalView() {
        localView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func removeRemoteView() {
        remoteView.subviews.forEach { $0.removeFromSuperview() }
    }
    
    func setupTytoCare() {
        tytoCareButton.isHidden = tytoCareManager == nil
        tytoCareButton.setupButton()
        tytoCareButton.buttonState = .closed
    }
    
    private func resizeStream(size: CGSize, containerHeight: CGFloat, widthConstraint: NSLayoutConstraint) {
        guard
            size.height != 0,
            containerHeight != 0
        else {
            return
        }
        
        widthConstraint.constant = (size.width * containerHeight) / size.height
    }
    
}
