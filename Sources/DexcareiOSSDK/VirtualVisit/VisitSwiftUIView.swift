// Copyright © 2024 DexCare. All rights reserved.

import SwiftUI

struct VisitSwiftUIView: View {
    @ObservedObject var viewModel: VisitViewModel

    private enum Constants {
        static let buttonSize: CGFloat = 46
        static let localViewWidth: CGFloat = 90
        static let localViewAspectRatio: CGFloat = 3.0 / 4.0
        static let animationDuration: Double = 0.25
    }

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            // Remote video feeds
            remoteVideoLayer

            // Bottom controls overlay
            VStack {
                Spacer()

                HStack(alignment: .bottom) {
                    // Local video + expand/collapse button
                    localVideoSection

                    Spacer()

                    VStack(alignment: .trailing, spacing: 15) {
                        // TytoCare button
                        if viewModel.showTytoCare {
                            TytoCareButtonRepresentable(tytoCareManager: viewModel.tytoCareManager)
                                .frame(width: 144, height: 54)
                        }

                        // Control bar
                        controlBar
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Remote Video Layer

    private var remoteVideoLayer: some View {
        GeometryReader { geometry in
            if viewModel.remoteVideoEntries.isEmpty {
                Color.black
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.remoteVideoEntries) { entry in
                        ZStack {
                            OpenTokVideoRepresentable(videoView: entry.view)
                            RemoteLabelRepresentable(label: entry.label)
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height / CGFloat(viewModel.remoteVideoEntries.count)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Local Video Section

    private var localVideoSection: some View {
        ZStack(alignment: .bottomLeading) {
            if let localView = viewModel.localVideoView, viewModel.isLocalViewExpanded {
                OpenTokVideoRepresentable(videoView: localView)
                    .frame(
                        width: Constants.localViewWidth,
                        height: Constants.localViewWidth / Constants.localViewAspectRatio
                    )
                    .clipped()
                    .transition(.scale(scale: 0, anchor: .bottomLeading).combined(with:
                      .opacity))
            }

            Button(action: {
                withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                    viewModel.isLocalViewExpanded.toggle()
                }
            }) {
                Image("ic_call_received_white", bundle: .dexcareSDK)
                    .rotationEffect(viewModel.isLocalViewExpanded ? .zero : .degrees(180))
            }
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
        }
    }

    // MARK: - Control Bar

    private var controlBar: some View {
        HStack(spacing: 2) {
            // Hangup button
            Button(action: { viewModel.manager?.hangup() }) {
                Image("ic_white_call_end", bundle: .dexcareSDK)
            }
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Color(red: 0.929, green: 0.231, blue: 0.318))

            // Mic toggle
            Button(action: { viewModel.manager?.toggleMic() }) {
                if let image = viewModel.micButtonImage {
                    Image(uiImage: image)
                } else {
                    Image("ic_white_mic", bundle: .dexcareSDK)
                }
            }
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Color(UIColor.buttonColor))

            // Camera toggle
            Button(action: { viewModel.manager?.toggleCamera() }) {
                if let image = viewModel.cameraButtonImage {
                    Image(uiImage: image)
                } else {
                    Image("ic_white_videocam", bundle: .dexcareSDK)
                }
            }
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Color(UIColor.buttonColor))

            // Camera position toggle
            if viewModel.showCameraPositionToggle {
                Button(action: { viewModel.manager?.toggleCameraPosition() }) {
                    Image("flip_camera_ios", bundle: .dexcareSDK)
                }
                .frame(width: Constants.buttonSize, height: Constants.buttonSize)
                .background(Color(UIColor.buttonColor))
            }

            // Chat button
            Button(action: { viewModel.manager?.openChat() }) {
                Image("ic_comment_white", bundle: .dexcareSDK)
            }
            .frame(width: Constants.buttonSize, height: Constants.buttonSize)
            .background(Color(UIColor.buttonColor))
        }
    }
}
