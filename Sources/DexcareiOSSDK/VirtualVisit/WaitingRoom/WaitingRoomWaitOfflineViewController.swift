//
//  WaitingRoomWaitOfflineViewController.swift
//  DexcareiOSSDK
//
//  Created by Daniel Johns on 2024-02-22.
//  Copyright © 2024 DexCare. All rights reserved.
//

import UIKit

class WaitingRoomWaitOfflineViewController: UIViewController {
    weak var manager: VirtualVisitManagerType?
    
    let titleLabel = UILabel(frame: .zero)
    let messageLabel = UILabel(frame: .zero)
    let cancelButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(doneButtonTapped))
        
        titleLabel.text = localizeString("waitingRoom_waitOffline_title")
        titleLabel.font = .boldSystemFont(ofSize: 18)
        
        messageLabel.text = localizeString("waitingRoom_waitOffline_message")
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        
        cancelButton.setTitle(localizeString("waitingRoom_link_cancelVisit"), for: .normal)
        cancelButton.setTitleColor(.buttonColor, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
                
        let stackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel, cancelButton])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 30
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16)
        ])
        
        view.backgroundColor = .white
    }
    
    @objc func doneButtonTapped() {
        manager?.waitOffline()
    }
    
    @objc func cancelButtonTapped() {
        manager?.cancelFromWaitOffline()
    }
}
