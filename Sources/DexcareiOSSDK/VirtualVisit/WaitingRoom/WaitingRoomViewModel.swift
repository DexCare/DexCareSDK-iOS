// Copyright © 2024 DexCare. All rights reserved.

import AVKit
import Combine
import Foundation

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

// @preconcurrency: WaitingRoomView is called from VirtualVisitOpenTokManager which is nonisolated
// but always dispatches on the main thread. Marking the protocol @MainActor would require refactoring
// all OpenTok delegate conformances in VirtualVisitOpenTokManager.
@MainActor
class WaitingRoomViewModel: ObservableObject, @preconcurrency WaitingRoomView {
    weak var manager: VirtualVisitManagerType?
    weak var tytoCareManager: TytoCareManagerType?
    var customizationOptions: CustomizationOptions?

    lazy var captureSessionHandler: CaptureSessionHandler = WaitingRoomCaptureSessionHandler()

    @Published var waitTimeMessage: String = ""
    @Published var estimateMessage: String = ""
    @Published var isSpinnerVisible: Bool = false
    @Published var canWaitOffline: Bool = false
    @Published var isTransferring: Bool = false
    @Published var isCancelButtonHidden: Bool = false
    @Published var isWaitOfflineHidden: Bool = true
    @Published var isEmbeddedVideoHidden: Bool = false
    @Published var showTytoCare: Bool = false

    var waitTimeSpinnerDuration: TimeInterval = 1.0
    var animationWorkItem: DispatchWorkItem?

    var showWaitingRoomVideo: Bool {
        customizationOptions?.virtualConfig?.showWaitingRoomVideo ?? true
    }

    var waitingRoomVideoURL: URL {
        customizationOptions?.virtualConfig?.waitingRoomVideoURL
            ?? URL(string: "https://player.vimeo.com/external/761626618.m3u8?s=076bcd1c5a021cadf70b6bcc20de180f5cb1ccb3")!
    }

    func configure() {
        showTytoCare = tytoCareManager != nil
        isEmbeddedVideoHidden = !showWaitingRoomVideo
        manager?.loadWaitTime()
    }

    // MARK: - WaitingRoomView Protocol

    func loadInitialWaitTime(waitTimeMessage: String, estimateMessage: String) {
        self.isSpinnerVisible = true
        self.waitTimeMessage = waitTimeMessage
        self.estimateMessage = estimateMessage
    }

    func updateWaitTime(waitTimeMessage: String, estimateMessage: String, canWaitOffline: Bool) {
        self.isSpinnerVisible = true

        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.waitTimeMessage = waitTimeMessage
            self.estimateMessage = estimateMessage
            self.isWaitOfflineHidden = !canWaitOffline
            self.isSpinnerVisible = false
            self.animationWorkItem = nil
        }
        animationWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + waitTimeSpinnerDuration, execute: workItem)
    }

    func abortedWaitTime() {
        isSpinnerVisible = false
    }

    func stopSelfPreview() {
        captureSessionHandler.stopCaptureSession()
    }

    func prepareForTransfer() {
        isEmbeddedVideoHidden = true
        isTransferring = true
        isCancelButtonHidden = true
        hideWaitOffline()
    }

    func hideWaitOffline() {
        isWaitOfflineHidden = true
    }
}
