//
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class CancelVisitAlertViewController: UIViewController {
    let reasons: [CancelReason]
    let onReasonSelected: (CancelReason) -> Void

    init(reasons: [CancelReason], onReasonSelected: @escaping (CancelReason) -> Void) {
        self.reasons = reasons
        self.onReasonSelected = onReasonSelected
        super.init(nibName: nil, bundle: nil)
        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let cancelVisitView = CancelVisitView(reasons: reasons) { [weak self] selectedReason in
            self?.onReasonSelected(selectedReason)
            self?.dismiss(animated: true, completion: nil)
        } onCancel: { [weak self] in
            self?.dismiss(animated: true, completion: nil)
        }

        let hostingController = UIHostingController(rootView: cancelVisitView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(backgroundView, at: 0)
    }
}

struct CancelVisitView: View {
    let reasons: [CancelReason]
    @State private var selectedReason: CancelReason = InternalCancelReason.default.cancelReason
    var onReasonSelected: (CancelReason) -> Void = { _ in }
    var onCancel: () -> Void = {}

    init(reasons: [CancelReason], onReasonSelected: @escaping (CancelReason) -> Void, onCancel: @escaping () -> Void) {
        self.onReasonSelected = onReasonSelected
        self.onCancel = onCancel
        self.reasons = reasons
        self.selectedReason = reasons.first ?? InternalCancelReason.default.cancelReason
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(localizeString("cancelVisit_confirmation_title"))
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.top)

            Text(localizeString("cancelVisit_confirmation_subtitle1"))
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Text(localizeString("cancelVisit_confirmation_subtitle2"))
                .font(.footnote)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            if #available(iOS 14.0, *) {
                reasonPickerWithMenuStyle
            } else {
                reasonPickerDefault
            }

            Button(action: {
                onReasonSelected(selectedReason)
            }) {
                Text(localizeString("cancelVisit_confirmation_confirm_button"))
                    .font(.body)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.buttonColor))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top, 32)

            Button(action: {
                onCancel()
            }) {
                Text(localizeString("cancelVisit_confirmation_cancel_button"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(Color(UIColor.buttonColor))
                    .cornerRadius(10)
            }

            Spacer()
        }
        .padding()
    }
    
    private var reasonPickerWithMenuStyle: some View {
        Picker("", selection: $selectedReason) {
            ForEach(reasons, id: \.code) { reason in
                Text(reason.displayText).tag(reason)
            }
        }
        .frame(maxWidth: .infinity)
        .pickerStyle(MenuPickerStyle())
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.buttonColor), lineWidth: 1)
        )
        .cornerRadius(10)
        .foregroundColor(Color(UIColor.buttonColor))
        .accentColor(Color(UIColor.buttonColor))
    }

    private var reasonPickerDefault: some View {
        Picker("", selection: $selectedReason) {
            ForEach(reasons, id: \.code) { reason in
                Text(reason.displayText).tag(reason)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(6)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(UIColor.buttonColor), lineWidth: 1)
        )
        .cornerRadius(10)
        .foregroundColor(Color(UIColor.buttonColor))
        .accentColor(Color(UIColor.buttonColor))
    }
}
