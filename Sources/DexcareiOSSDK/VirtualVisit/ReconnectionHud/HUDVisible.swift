// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import MBProgressHUD

enum DesiredHUDVisibility {
    case shouldBeVisible, shouldNotBeVisible
}

enum HUDVisibility {
    case isVisible, isNotVisible
}

protocol HUDVisible {
    var currentHUDVisibility: HUDVisibility { get }
    func updateHUD(desiredVisibility: DesiredHUDVisibility, didCancel: @escaping (() -> Void))
}

extension HUDVisible where Self: UIViewController {
    func updateHUD(desiredVisibility: DesiredHUDVisibility, didCancel: @escaping (() -> Void)) {
        switch (currentHUDVisibility, desiredVisibility) {
        case (.isNotVisible, .shouldBeVisible):
            showHUD(didCancel: didCancel)
        case (.isVisible, .shouldNotBeVisible):
            hideHUD()
        default:
            break
        }
    }

    var currentHUDVisibility: HUDVisibility {
        return (MBProgressHUD.forView(view) != nil) ? .isVisible : .isNotVisible
    }

    func showHUD(didCancel: @escaping () -> Void) {
        MBProgressHUD.showReconnectionHudAdded(to: view, animated: true, didCancel: didCancel)
    }

    func hideHUD() {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

extension UIViewController: HUDVisible {}
