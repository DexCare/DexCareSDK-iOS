// Copyright © 2024 DexCare. All rights reserved.

import SwiftUI

struct WaitingRoomSwiftUIView: View {
    @ObservedObject var viewModel: WaitingRoomViewModel

    var body: some View {
        VStack(spacing: 15) {
            // Embedded video
            if !viewModel.isEmbeddedVideoHidden {
                EmbeddedVideoRepresentable(
                    videoURL: viewModel.waitingRoomVideoURL,

                )
                .aspectRatio(320.0 / 180.0, contentMode: .fit)
            }

            // Transfer banner
            if viewModel.isTransferring {
                transferBanner
            }

            // Wait time section
            waitTimeSection
            
            Spacer()

            // Bottom section with preview and buttons
            bottomSection
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle(localizeString("waitingRoom_title_navigation"))
        .onAppear {
            viewModel.captureSessionHandler.startCaptureSession()
            viewModel.configure()
        }
        .onDisappear {
            viewModel.captureSessionHandler.stopCaptureSession()
        }
    }

    // MARK: - Transfer Banner

    private var transferBanner: some View {
        HStack {
            Text(localizeString("waitingRoom_message_patientTransfer"))
                .font(.system(size: 17))
                .padding(.leading, 20)
                .padding(.top, 20)
            Spacer()
            Button(localizeString("waitingRoom_message_dismiss")) {
                viewModel.isTransferring = false
            }
            .padding(.trailing, 20)
        }
        .background(Color(UIColor.systemBackground))
    }

    // MARK: - Wait Time Section

    private var waitTimeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.waitTimeMessage)
                .font(.system(size: 16))
                .accessibilityIdentifier("WAITTIME_MESSAGE")
                .accessibilityAddTraits(.updatesFrequently)

            HStack(spacing: 4) {
                Text(viewModel.estimateMessage)
                    .font(.system(size: 14))
                    .foregroundColor(Color(red: 0.4, green: 0.4, blue: 0.4))
                    .accessibilityIdentifier("ESTIMATE_MESSAGE")
                    .accessibilityAddTraits(.updatesFrequently)

                if viewModel.isSpinnerVisible {
                    ProgressView()
                }
            }

            // Wait offline
            if !viewModel.isWaitOfflineHidden {
                HStack {
                    Text(localizeString("waitingRoom_message_waitOfflinePrompt"))
                        .font(.system(size: 16))
                    Button(localizeString("waitingRoom_link_waitOffline")) {
                        viewModel.manager?.showWaitOfflineAlert()
                    }
                    .accessibilityIdentifier("CANCEL_BUTTON")
                }
            }

            Text(localizeString("waitingRoom_message_readyPhotoId"))
                .font(.system(size: 16))
                .accessibilityIdentifier("NOTIFICATION_MESSAGE")

            if !viewModel.isCancelButtonHidden {
                Button(localizeString("waitingRoom_link_cancelVisit")) {
                    if viewModel.isEmbeddedVideoHidden {
                        viewModel.manager?.leave()
                    } else {
                        viewModel.manager?.cancel()
                    }
                }
                .accessibilityIdentifier("CANCEL_BUTTON")
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    // MARK: - Bottom Section

    private var bottomSection: some View {
        HStack(alignment: .bottom) {
            // Self video preview
            CameraPreviewRepresentable(captureSessionHandler: viewModel.captureSessionHandler)
                .frame(width: 85, height: 118)
                .background(Color.black)
                .accessibilityIdentifier("SELF_VIDEO_VIEW")
                .accessibilityLabel("Your Video Preview")

            Spacer()

            VStack(alignment: .trailing, spacing: 15) {
                // TytoCare button
                if viewModel.showTytoCare {
                    TytoCareButtonRepresentable(tytoCareManager: viewModel.tytoCareManager)
                        .frame(width: 144, height: 54)
                }

                // Chat button
                Button(action: {
                    viewModel.manager?.openChat()
                }) {
                    Image("ic_comment_white", bundle: .dexcareSDK)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .padding(15)
                }
                .frame(width: 54, height: 54)
                .background(Color(UIColor.buttonColor))
                .accessibilityIdentifier("QUESTION_BUTTON")
                .accessibilityLabel("Chat with our providers")
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

// MARK: - TytoCare Button Wrapper

struct TytoCareButtonRepresentable: UIViewRepresentable {
    weak var tytoCareManager: TytoCareManagerType?

    func makeUIView(context: Context) -> TytoCareButton {
        let button = TytoCareButton(type: .custom)
        button.setupButton()
        button.backgroundColor = UIColor(named: "tytoCarePurple", in: .dexcareSDK, compatibleWith: nil)
        button.setTitle("Pair device", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tytocareButtonTapped), for: .touchUpInside)
        return button
    }

    func updateUIView(_ uiView: TytoCareButton, context: Context) {
        context.coordinator.tytoCareManager = tytoCareManager
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(tytoCareManager: tytoCareManager)
    }

    class Coordinator: NSObject {
        weak var tytoCareManager: TytoCareManagerType?

        init(tytoCareManager: TytoCareManagerType?) {
            self.tytoCareManager = tytoCareManager
        }

        @objc func tytocareButtonTapped() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let rootVC = windowScene.windows.first?.rootViewController else { return }
            var topVC = rootVC
            while let presented = topVC.presentedViewController {
                topVC = presented
            }
            tytoCareManager?.openTytoCare(from: topVC)
        }
    }
}
