// Copyright © 2019 DexCare. All rights reserved.

import AVKit
import Foundation
import UIKit

protocol WaitingRoomView: AnyObject {
    var manager: VirtualVisitManagerType? { get set }
    var tytoCareManager: TytoCareManagerType? { get set }

    func loadInitialWaitTime(waitTimeMessage: String, estimateMessage: String)
    func updateWaitTime(waitTimeMessage: String, estimateMessage: String, canWaitOffline: Bool)
    func abortedWaitTime()
    func stopSelfPreview()
    func prepareForTransfer()
    func hideWaitOffline()
}

class WaitingRoomViewController: UIViewController, WaitingRoomView {
    weak var manager: VirtualVisitManagerType?
    weak var tytoCareManager: TytoCareManagerType?
    var customizationOptions: CustomizationOptions?

    lazy var captureSessionHandler: CaptureSessionHandler = WaitingRoomCaptureSessionHandler()
    private(set) var embeddedVideoViewController: EmbeddedVideoViewController?

    @IBOutlet weak var transferContainer: UIView!
    @IBOutlet weak var transferLabel: UILabel! {
        didSet {
            transferLabel.text = localizeString("waitingRoom_message_patientTransfer")
        }
    }

    @IBOutlet weak var transferDismissButton: UIButton! {
        didSet {
            transferDismissButton.setTitle(localizeString("waitingRoom_message_dismiss"), for: .normal)
        }
    }

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var estimateLabel: UILabel!
    @IBOutlet weak var estimateSpinner: UIActivityIndicatorView!
    @IBOutlet weak var waitOfflineContainer: UIView!
    @IBOutlet weak var waitOfflineMessageLabel: UILabel! {
        didSet {
            waitOfflineMessageLabel.text = localizeString("waitingRoom_message_waitOfflinePrompt")
        }
    }

    @IBOutlet weak var waitOfflineButton: UIButton!
    @IBOutlet weak var notificationMessageLabel: UILabel! {
        didSet {
            notificationMessageLabel.text = localizeString("waitingRoom_message_readyPhotoId")
        }
    }

    @IBOutlet private(set) weak var chatButton: UIButton!
    @IBOutlet private(set) weak var cancelVisitButton: UIButton!
    @IBOutlet private(set) weak var previewSelfVideoView: PreviewView!

    @IBOutlet weak var embeddedContainerView: UIView!

    @IBOutlet private(set) weak var tytoCareButton: TytoCareButton!
    @IBOutlet weak var tytoWidthConstraint: NSLayoutConstraint! {
        didSet {
            tytoCareButton.widthConstraint = tytoWidthConstraint
        }
    }

    var waitTimeSpinnerDuration = 1.0
    var animationWorkItem: DispatchWorkItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = localizeString("waitingRoom_title_navigation")

        previewSelfVideoView.videoPreviewLayer.session = captureSessionHandler.captureSession
        previewSelfVideoView.videoPreviewLayer.videoGravity = .resizeAspectFill
        captureSessionHandler.configureAVCaptureSession { [weak self] in
            self?.previewSelfVideoView.videoPreviewLayer.connection?.videoOrientation = .portrait
        }
        loadVideo()
        manager?.loadWaitTime()
        chatButton.backgroundColor = .buttonColor

        let cancelButtonTitle = localizeString("waitingRoom_link_cancelVisit")
        cancelVisitButton.setTitle(cancelButtonTitle, for: .normal)

        let waitOfflineButtonTitle = localizeString("waitingRoom_link_waitOffline")
        waitOfflineButton.setTitle(waitOfflineButtonTitle, for: .normal)
        waitOfflineContainer.isHidden = true // Starts hidden, only shown when available

        setupTytoCare()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSelfPreview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSelfPreview()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let embeddedVideoViewController = segue.destination as? EmbeddedVideoViewController {
            self.embeddedVideoViewController = embeddedVideoViewController
        }
    }

    private func loadVideo() {
        guard customizationOptions?.virtualConfig?.showWaitingRoomVideo ?? true else {
            self.embeddedVideoViewController = nil
            self.embeddedContainerView.isHidden = true
            return
        }

        guard let embeddedVideoViewController = embeddedVideoViewController else {
            assertionFailure("Tried to load video before video controller was loaded; wait until the video is loaded")
            return
        }

        let customVideoURL = self.customizationOptions?.virtualConfig?.waitingRoomVideoURL
        if let customVideoURL = customVideoURL {
            embeddedVideoViewController.loadVideo(url: customVideoURL)
        } else {
            let defaultVideoURL = URL(string: "https://player.vimeo.com/external/761626618.m3u8?s=076bcd1c5a021cadf70b6bcc20de180f5cb1ccb3")!
            embeddedVideoViewController.loadVideo(url: defaultVideoURL)
        }
    }

    private func setupTytoCare() {
        tytoCareButton.isHidden = tytoCareManager == nil
        tytoCareButton.setupButton()
    }

    // MARK: - IBActions

    @IBAction func waitOfflineButtonTapped() {
        manager?.showWaitOfflineAlert()
    }

    @IBAction func cancelButtonTapped() {
        if embeddedContainerView.isHidden {
            manager?.leave()
        } else {
            manager?.cancel()
        }
    }

    @IBAction func chatButtonTapped() {
        manager?.openChat()
    }

    @IBAction func tytocareButtonTapped() {
        tytoCareManager?.openTytoCare(from: self)
    }

    @IBAction func dismissTransferMessage() {
        transferContainer.isHidden = true
    }

    // MARK: - Self Preview

    func stopSelfPreview() {
        captureSessionHandler.stopCaptureSession()
    }

    func startSelfPreview() {
        captureSessionHandler.startCaptureSession()
    }

    // MARK: - Wait Time Messages

    func loadInitialWaitTime(waitTimeMessage: String, estimateMessage: String) {
        estimateSpinner.alpha = 1.0
        estimateSpinner.startAnimating()
        messageLabel.text = waitTimeMessage
        estimateLabel.text = estimateMessage
    }

    func updateWaitTime(waitTimeMessage: String, estimateMessage: String, canWaitOffline: Bool) {
        estimateSpinner.alpha = 1.0
        estimateSpinner.startAnimating()

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }

            self.messageLabel.text = waitTimeMessage

            UIView.transition(
                with: self.estimateLabel,
                duration: 0.5,
                options: [.transitionFlipFromBottom],
                animations: {
                    self.estimateLabel.text = estimateMessage
                    self.estimateSpinner.alpha = 0.0
                    self.waitOfflineContainer.isHidden = !canWaitOffline
                },
                completion: { _ in
                    self.estimateSpinner.stopAnimating()
                    self.animationWorkItem = nil
                }
            )
        }
        animationWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + waitTimeSpinnerDuration, execute: workItem)
    }

    func abortedWaitTime() {
        estimateSpinner.alpha = 0.0
        estimateSpinner.stopAnimating()
    }

    // MARK: - Transfer

    func prepareForTransfer() {
        embeddedContainerView.isHidden = true
        transferContainer.isHidden = false
        cancelVisitButton.isHidden = true
        hideWaitOffline()
    }

    func hideWaitOffline() {
        waitOfflineContainer.isHidden = true
    }
}
