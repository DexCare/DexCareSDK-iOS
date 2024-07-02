// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import AVKit

class EmbeddedVideoViewController: UIViewController {
    
    @IBOutlet weak private(set) var pausedOverlayView: UIView!
    @IBOutlet weak private(set) var replayOverlayView: UIView!
    @IBOutlet weak private(set) var replayLabel: UILabel!
    @IBOutlet weak private(set) var videoOverlayImageView: UIImageView!
    
    private let videoPlayerViewController = AVPlayerViewController()
    private var isVideoDone: Bool = false
    private var videoObservation: NSKeyValueObservation?
    
    typealias VideoEventCallback = () -> ()
    var onVideoFirstPlayed: VideoEventCallback?
    var onUserPausedVideo: VideoEventCallback?
    var onUserUnpausedVideo: VideoEventCallback?
    var onUserReplayedVideo: VideoEventCallback?
    var onVideoFinished: VideoEventCallback?
    
    /// Add the AVPlayer view to the container view, and setup notifications
    private func configure() {
        do {
            // In order for the audio to play when phone is in silent mode, reset AVAudioSession category
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch let error {
            assertionFailure("Error in AVAudio Session \(error.localizedDescription)")
        }
        
        view.insertSubview(videoPlayerViewController.view, at: 0) // Add the AVPlayer at the very bottom
        videoPlayerViewController.showsPlaybackControls = false
        videoPlayerViewController.view.isUserInteractionEnabled = false // Disable touch for AVPlayer since we are handling it in the overlay
        
        guard let videoView = videoPlayerViewController.view else {
            assertionFailure("Unable to fetch AVPlayerViewController view, make sure `configureVideo` is called after the views are loaded")
            return
        }
        
        videoView.translatesAutoresizingMaskIntoConstraints = false
        videoView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        videoView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(toggleVideoPlayback))
        view.addGestureRecognizer(tapGestureRecognizer)
        
        refreshOverlay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(videoFinishedPlaying), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        pauseVideoPlayback()
    }
    
    // MARK: - Video playback
    private var isPlayerSetup: Bool {
        return videoPlayerViewController.player != nil
    }
    
    private var isVideoPlaying: Bool {
        return videoPlayerViewController.player?.timeControlStatus != .paused
    }
    
    /// Load and play a url in the AVPlayer
    ///
    /// - Parameter url: URL to the video
    func loadVideo(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        // per https://developer.apple.com/documentation/avfoundation/avplayeritem, only way to get notified of changes on this object is to use KVO.
        videoObservation = playerItem.observe(\AVPlayerItem.status, options: .new, changeHandler: { (playerItem, _) -> Void in
            if playerItem.status == .failed {
                self.showPlaceholder()
            }
        })
        
        let preferredLocale = Locale.preferredLanguages[0]
        
        if let player = self.videoPlayerViewController.player {
            player.replaceCurrentItem(with: playerItem)
        } else {
            let player = AVPlayer(playerItem: playerItem)
            // if we're not english - lets put on the the subtitles on the hls stream if we can
            if !preferredLocale.lowercased().contains("en") {
                let option = AVPlayerMediaSelectionCriteria(preferredLanguages: [preferredLocale, "en"], preferredMediaCharacteristics: [AVMediaCharacteristic.legible])
                
                player.setMediaSelectionCriteria(option, forMediaCharacteristic: .legible)
            }
            self.videoPlayerViewController.player = player
        }
        
        resumeVideoPlayback()
    }
    
    /// Hide the video and show a placeholder view
    func showPlaceholder() {
        pauseVideoPlayback()
        videoPlayerViewController.view.isHidden = true
        replayOverlayView.isHidden = true
        pausedOverlayView.isHidden = true
        videoOverlayImageView.isHidden = false
    }
    
    private func refreshOverlay() {
        replayOverlayView.isHidden = !(isVideoDone && isPlayerSetup)
        pausedOverlayView.isHidden = isVideoPlaying
    }
    
    func pauseVideoPlayback() {
        guard isVideoPlaying else { return }
        videoPlayerViewController.player?.pause()
        refreshOverlay()
    }
    
    var videoHasPlayed = false
    private func resumeVideoPlayback() {
        if !isVideoDone {
            videoPlayerViewController.player?.play()
            if !videoHasPlayed {
                self.onVideoFirstPlayed?()
            }
            videoHasPlayed = true
        }
        refreshOverlay()
    }
    
    @IBAction func toggleVideoPlayback() {
        if isVideoPlaying {
            onUserPausedVideo?()
            pauseVideoPlayback()
        } else {
            onUserUnpausedVideo?()
            resumeVideoPlayback()
        }
    }
    
    // MARK: - Notifications
    
    @objc func videoFinishedPlaying() {
        isVideoDone = true
        onVideoFinished?()
        refreshOverlay()
    }
    
    @objc func applicationDidEnterBackground() {
        pauseVideoPlayback()
    }
    
    // MARK: - IBActions
    
    @IBAction func replayButtonTapped() {
        videoPlayerViewController.player?.seek(to: .zero)
        isVideoDone = false
        onUserReplayedVideo?()
        resumeVideoPlayback()
    }
}
