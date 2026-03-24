// Copyright © 2024 DexCare. All rights reserved.

import SwiftUI
import UIKit

struct VirtualVisitAlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?
}

struct VirtualVisitAlertFooter {
    let title: String
    let action: VirtualVisitAlertAction
}

struct VirtualVisitAlertSwiftUIView: View {
    let titleString: String?
    let message: String?
    let actions: [VirtualVisitAlertAction]
    let footer: VirtualVisitAlertFooter?
    let dismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture { dismiss() }

            VStack(spacing: 20) {
                if let titleString {
                    Text(titleString)
                        .font(.system(size: 18, weight: .bold))
                        .multilineTextAlignment(.center)
                }

                if let message {
                    Text(message)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)
                }

                ForEach(Array(actions.enumerated()), id: \.offset) { _, action in
                    alertButton(for: action)
                }

                if let footer {
                    Divider()

                    Text(footer.title)
                        .font(.system(size: 14))
                        .multilineTextAlignment(.center)

                    alertButton(for: footer.action)
                }
            }
            .padding(30)
            .background(Color(UIColor.tertiarySystemBackground))
            .cornerRadius(20)
            .padding(.horizontal, 20)
        }
        .background(ClearBackground())
    }

    @ViewBuilder
    private func alertButton(for action: VirtualVisitAlertAction) -> some View {
        Button(action: {
            dismiss()
            action.handler?()
        }) {
            Text(action.title.uppercased())
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .padding(.horizontal, 20)
        }
        .background(buttonBackground(for: action.style))
        .foregroundColor(buttonForegroundColor(for: action.style))
        .overlay(
            Capsule()
                .stroke(buttonBorderColor(for: action.style), lineWidth: 2)
        )
        .clipShape(Capsule())
    }

    private func buttonBackground(for style: UIAlertAction.Style) -> Color {
        switch style {
        case .default:
            return Color(UIColor.buttonColor)
        case .cancel, .destructive:
            return .white
        @unknown default:
            return Color(UIColor.buttonColor)
        }
    }

    private func buttonForegroundColor(for style: UIAlertAction.Style) -> Color {
        switch style {
        case .default:
            return .white
        case .cancel:
            return Color(UIColor.buttonColor)
        case .destructive:
            return Color(UIColor.error)
        @unknown default:
            return .white
        }
    }

    private func buttonBorderColor(for style: UIAlertAction.Style) -> Color {
        switch style {
        case .default, .cancel:
            return Color(UIColor.buttonColor)
        case .destructive:
            return Color(UIColor.error)
        @unknown default:
            return Color(UIColor.buttonColor)
        }
    }
}

private struct ClearBackground: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
