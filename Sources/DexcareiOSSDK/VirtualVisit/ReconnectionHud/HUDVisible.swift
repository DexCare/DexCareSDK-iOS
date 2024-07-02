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
    func updateHUD(desiredVisibility: DesiredHUDVisibility, didCancel: @escaping (() -> ()))
}

extension HUDVisible where Self: UIViewController {
    func updateHUD(desiredVisibility: DesiredHUDVisibility, didCancel: @escaping (() -> ())) {
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
    
    internal func showHUD(didCancel: @escaping () -> ()) {
        MBProgressHUD.showReconnectionHudAdded(to: view, animated: true, didCancel: didCancel)
    }
    
    internal func hideHUD() {
        MBProgressHUD.hide(for: view, animated: true)
    }
}

extension UIViewController: HUDVisible {}
