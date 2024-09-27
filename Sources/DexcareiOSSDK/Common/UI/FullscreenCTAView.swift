//
//  FullscreenCTAView.swift
//  DexcareiOSSDK
//
//  Created by Dominic Pepin on 2024-07-10.
//  Copyright © 2024 DexCare. All rights reserved.
//

import SwiftUI

struct FullscreenCTAView: View {
    // MARK: Properties

    private let title: String
    private let message: String
    private let onActionString: String?
    private let onAction: (() -> Void)?

    // MARK: Body

    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            titleView()
            messageView()
            actionView()
            Spacer()
        }
        .background(Color(UIColor.systemBackground))
        .padding()
    }

    // MARK: Lifecycle

    init(
        title: String,
        message: String,
        onActionString: String?,
        onAction: (() -> Void)?
    ) {
        self.title = title
        self.message = message
        self.onActionString = onActionString
        self.onAction = onAction
    }

    // MARK: Private Views

    @ViewBuilder
    private func actionView() -> some View {
        if let onActionString {
            HStack {
                Spacer()
                Button(action: {
                    onAction?()
                }, label: {
                    Text(onActionString)
                        .foregroundColor(Color(UIColor.buttonColor))
                })
                Spacer()
            }
        }
    }

    private func messageView() -> some View {
        Text(message)
            .foregroundColor(Color(UIColor.label))
            .font(.system(size: 16))
            .multilineTextAlignment(.center)
    }

    private func titleView() -> some View {
        Text(title)
            .foregroundColor(Color(UIColor.label))
            .font(.system(size: 18))
            .bold()
            .multilineTextAlignment(.center)
    }
}

struct FullscreenCTAView_Previews: PreviewProvider {
    static var previews: some View {
        FullscreenCTAView(
            title: "Title",
            message: "Welcome to this fullscreen CTA",
            onActionString: "Dismiss",
            onAction: {}
        )
    }
}
