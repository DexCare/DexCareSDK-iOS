// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import UIKit

extension UIView {
    func addAndClampToEdges(of parentView: UIView, margins: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        parentView.addSubview(self)

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: margins),
            trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -margins),
            topAnchor.constraint(equalTo: parentView.topAnchor, constant: margins),
            bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -margins),
        ])
    }
}
