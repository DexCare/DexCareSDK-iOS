//
//  FullscreenCTAViewController.swift
//  DexcareiOSSDK
//
//  Created by Dominic Pepin on 2024-07-10.
//  Copyright © 2024 DexCare. All rights reserved.
//

import Foundation
import SwiftUI

/// ViewController wrapper around the FullscreenCTAView
class FullscreenCTAViewController: UIViewController {
    private let viewTitle: String
    private let message: String
    private let onActionString: String?
    private let onAction: (() -> Void)?
    private let onClose: () -> Void

    init(
        title: String,
        message: String,
        onActionString: String?,
        onAction: (() -> Void)?,
        onClose: @escaping () -> Void
    ) {
        self.viewTitle = title
        self.message = message
        self.onActionString = onActionString
        self.onAction = onAction
        self.onClose = onClose
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let hostingController = UIHostingController(rootView: FullscreenCTAView(
            title: viewTitle,
            message: message,
            onActionString: onActionString,
            onAction: onAction
        ))
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

        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
    }

    @objc func closeButtonTapped() {
        onClose()
    }
}
