//
//  VirtualVisitAlertViewController.swift
//  DexcareiOSSDK
//
//  Created by Daniel Johns on 2024-02-06.
//  Copyright © 2024 DexCare. All rights reserved.
//

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

class VirtualVisitAlertViewController: UIViewController {
    let titleString, message: String?
    let actions: [VirtualVisitAlertAction]
    let footer: VirtualVisitAlertFooter?

    let stackView = UIStackView(arrangedSubviews: [])

    init(title: String?, message: String? = nil, actions: [VirtualVisitAlertAction] = [], footer: VirtualVisitAlertFooter? = nil) {
        self.titleString = title
        self.message = message
        self.actions = actions
        self.footer = footer

        super.init(nibName: nil, bundle: nil)

        modalTransitionStyle = .crossDissolve
        modalPresentationStyle = .overFullScreen
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        if let titleString {
            let titleLabel = UILabel(frame: .zero)
            titleLabel.text = titleString
            titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
            titleLabel.numberOfLines = 0
            titleLabel.textAlignment = .center

            stackView.addArrangedSubview(titleLabel)
        }
        if let message {
            let messageLabel = UILabel(frame: .zero)
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 14)
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center

            stackView.addArrangedSubview(messageLabel)
        }

        actions.forEach {
            stackView.addArrangedSubview(VirtualVisitAlertButton(action: $0) { [weak self] in self?.dismissDialog() })
        }

        if let footer {
            let divider = UIView(frame: .zero)
            divider.addConstraint(divider.heightAnchor.constraint(equalToConstant: 1))
            divider.backgroundColor = UIColor.divider
            stackView.addArrangedSubview(divider)

            let footerLabel = UILabel(frame: .zero)
            footerLabel.text = footer.title
            footerLabel.font = UIFont.systemFont(ofSize: 14)
            footerLabel.numberOfLines = 0
            footerLabel.textAlignment = .center
            stackView.addArrangedSubview(footerLabel)

            stackView.addArrangedSubview(VirtualVisitAlertButton(action: footer.action) { [weak self] in self?.dismissDialog() })
        }

        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 20

        let stackViewWrapper = UIView(frame: .zero)
        stackViewWrapper.backgroundColor = .tertiarySystemBackground
        stackViewWrapper.layer.cornerRadius = 20
        stackViewWrapper.layer.masksToBounds = true
        stackView.addAndClampToEdges(of: stackViewWrapper, margins: 30)

        let background = UIView(frame: .zero)
        background.backgroundColor = .black.withAlphaComponent(0.4)
        background.addAndClampToEdges(of: view)
        background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissDialog)))

        view.addSubview(stackViewWrapper)
        stackViewWrapper.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints([
            stackViewWrapper.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackViewWrapper.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackViewWrapper.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
        ])
    }

    @objc func dismissDialog() {
        dismiss(animated: true)
    }
}

class VirtualVisitAlertButton: UIButton {
    let actionHandler: (() -> Void)?
    let completion: () -> Void

    init(action: VirtualVisitAlertAction, onCompletion: @escaping () -> Void) {
        actionHandler = action.handler
        completion = onCompletion

        super.init(frame: .zero)

        addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        setTitle(action.title.uppercased(), for: .normal)
        layer.borderWidth = 2
        contentEdgeInsets = UIEdgeInsets(top: 10, left: 20, bottom: 10, right: 20)

        switch action.style {
        case .default:
            layer.borderColor = UIColor.buttonColor.cgColor
            backgroundColor = .buttonColor
            setTitleColor(.white, for: .normal)
        case .cancel:
            layer.borderColor = UIColor.buttonColor.cgColor
            backgroundColor = .white
            setTitleColor(.buttonColor, for: .normal)
        case .destructive:
            layer.borderColor = UIColor.error.cgColor
            backgroundColor = .white
            setTitleColor(.error, for: .normal)
        @unknown default:
            layer.borderColor = UIColor.buttonColor.cgColor
            backgroundColor = .buttonColor
            setTitleColor(.white, for: .normal)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2.0
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func buttonTapped() {
        completion()
        actionHandler?()
    }
}
