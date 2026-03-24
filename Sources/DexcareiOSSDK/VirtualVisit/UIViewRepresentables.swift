// Copyright © 2024 DexCare. All rights reserved.

import AVKit
import SwiftUI
import UIKit

struct OpenTokVideoRepresentable: UIViewRepresentable {
    let videoView: UIView

    func makeUIView(context: Context) -> UIView {
        videoView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct RemoteLabelRepresentable: UIViewRepresentable {
    let label: UILabel

    func makeUIView(context: Context) -> UILabel {
        label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {}
}

struct CameraPreviewRepresentable: UIViewRepresentable {
    let captureSessionHandler: CaptureSessionHandler

    func makeUIView(context: Context) -> PreviewView {
        let previewView = PreviewView()
        previewView.videoPreviewLayer.session = captureSessionHandler.captureSession
        previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.backgroundColor = .black
        captureSessionHandler.configureAVCaptureSession {
            previewView.videoPreviewLayer.connection?.videoOrientation = .portrait
        }
        return previewView
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {}
}

final class EmbeddedVideoCoordinator: NSObject {
    let parent: EmbeddedVideoRepresentable
    var videoObservation: NSKeyValueObservation?
    var isVideoDone = false
    var videoHasPlayed = false
    weak var playerViewController: AVPlayerViewController?

    init(_ parent: EmbeddedVideoRepresentable) {
        self.parent = parent
    }

    @objc func videoFinishedPlaying(_ notification: Notification) {
        isVideoDone = true
        parent.onVideoFinished?()
    }

    @objc func applicationDidEnterBackground(_ notification: Notification) {
        playerViewController?.player?.pause()
    }
}

struct EmbeddedVideoRepresentable: UIViewControllerRepresentable {
    let videoURL: URL?
    var onVideoFirstPlayed: (() -> Void)?
    var onVideoFinished: (() -> Void)?

    func makeCoordinator() -> EmbeddedVideoCoordinator {
        EmbeddedVideoCoordinator(self)
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerVC = AVPlayerViewController()
        playerVC.showsPlaybackControls = true
        playerVC.view.isUserInteractionEnabled = true
        playerVC.view.backgroundColor = .black

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            assertionFailure("Error in AVAudio Session \(error.localizedDescription)")
        }

        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(EmbeddedVideoCoordinator.videoFinishedPlaying(_:)),
            name: .AVPlayerItemDidPlayToEndTime,
            object: nil
        )
        NotificationCenter.default.addObserver(
            context.coordinator,
            selector: #selector(EmbeddedVideoCoordinator.applicationDidEnterBackground(_:)),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )

        if let videoURL {
            loadVideo(url: videoURL, into: playerVC, coordinator: context.coordinator)
        }

        context.coordinator.playerViewController = playerVC

        return playerVC
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {}

    static func dismantleUIViewController(_ uiViewController: AVPlayerViewController, coordinator: EmbeddedVideoCoordinator) {
        uiViewController.player?.pause()
        uiViewController.player = nil
        coordinator.videoObservation?.invalidate()
        coordinator.videoObservation = nil
        NotificationCenter.default.removeObserver(coordinator)
    }

    private func loadVideo(url: URL, into playerVC: AVPlayerViewController, coordinator: EmbeddedVideoCoordinator) {
        let playerItem = AVPlayerItem(url: url)
        coordinator.videoObservation = playerItem.observe(\.status, options: .new) { item, _ in
            if item.status == .failed {
                playerVC.view.isHidden = true
            }
        }

        let preferredLocale = Locale.preferredLanguages[0]

        if let player = playerVC.player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            let player = AVPlayer(playerItem: playerItem)
            if !preferredLocale.lowercased().contains("en") {
                let option = AVPlayerMediaSelectionCriteria(
                    preferredLanguages: [preferredLocale, "en"],
                    preferredMediaCharacteristics: [.legible]
                )
                player.setMediaSelectionCriteria(option, forMediaCharacteristic: .legible)
            }
            playerVC.player = player
        }

        playerVC.player?.play()
        if !coordinator.videoHasPlayed {
            onVideoFirstPlayed?()
        }
        coordinator.videoHasPlayed = true
    }
}
