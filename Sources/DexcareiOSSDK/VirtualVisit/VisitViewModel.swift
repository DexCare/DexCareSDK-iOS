// Copyright © 2024 DexCare. All rights reserved.

import Combine
import Foundation
import UIKit

protocol VisitView: AnyObject {
    var manager: VirtualVisitManagerType? { get set }
    var tytoCareManager: TytoCareManagerType? { get set }

    var micButtonImage: UIImage? { get set }
    var cameraButtonImage: UIImage? { get set }

    var showCameraPositionToggle: Bool { get set }

    func addLocalView(_ view: UIView, resolutionSize: CGSize)
    func addRemoteView(_ view: UIView, _ label: UILabel, resolutionSize: CGSize)
    func removeLocalView()
    func removeRemoteView()
    func removeSpecificRemoteView(_ view: UIView)
}

struct RemoteVideoEntry: Identifiable {
    let id = UUID()
    let view: UIView
    let label: UILabel
    let resolution: CGSize
}

// @preconcurrency: VisitView is called from VirtualVisitOpenTokManager which is nonisolated
// but always dispatches on the main thread. Marking the protocol @MainActor would require refactoring
// all OpenTok delegate conformances in VirtualVisitOpenTokManager.
@MainActor
class VisitViewModel: ObservableObject, @preconcurrency VisitView {
    weak var manager: VirtualVisitManagerType?
    weak var tytoCareManager: TytoCareManagerType? {
        didSet {
            showTytoCare = tytoCareManager != nil
        }
    }

    @Published var micButtonImage: UIImage?
    @Published var cameraButtonImage: UIImage?
    @Published var showCameraPositionToggle: Bool = false
    @Published var showTytoCare: Bool = false

    @Published var localVideoView: UIView?
    @Published var localVideoResolution: CGSize = .zero
    @Published var isLocalViewExpanded: Bool = true

    @Published var remoteVideoEntries: [RemoteVideoEntry] = []

    private enum Constants {
        static var localViewWidth: CGFloat = 90.0
    }

    // MARK: - VisitView Protocol

    func addLocalView(_ view: UIView, resolutionSize: CGSize) {
        localVideoView = view
        localVideoResolution = resolutionSize
    }

    func addRemoteView(_ view: UIView, _ label: UILabel, resolutionSize: CGSize) {
        label.text = "This user's video has been temporarily turned off."
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.isHidden = true

        let entry = RemoteVideoEntry(
            view: view,
            label: label,
            resolution: resolutionSize
        )
        remoteVideoEntries.append(entry)
    }

    func removeLocalView() {
        localVideoView = nil
    }

    func removeRemoteView() {
        remoteVideoEntries.removeAll()
    }

    func removeSpecificRemoteView(_ view: UIView) {
        remoteVideoEntries.removeAll { $0.view === view }
    }
}
