// Copyright © 2024 DexCare. All rights reserved.

import SwiftUI

struct ReconnectionHudSwiftUIView: View {
    let didCancel: () -> Void

    private enum Constants {
        static let cornerRadius: CGFloat = 18.0
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                ProgressView()
                    .scaleEffect(1.75)
                    .padding(.top, 10)

                Text(localizeString("dialog_reconnect_title"))
                    .font(.system(size: 17))

                Button(localizeString("dialog_reconnect_cancel")) {
                    didCancel()
                }
                .padding(.bottom, 10)
            }
            .padding(30)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(Constants.cornerRadius)
        }
        .background(ReconnectionClearBackground())
    }
}

private struct ReconnectionClearBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
