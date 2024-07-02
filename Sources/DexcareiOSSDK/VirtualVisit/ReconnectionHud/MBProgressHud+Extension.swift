// Copyright © 2018 DexCare. All rights reserved.

import Foundation
import MBProgressHUD

extension MBProgressHUD {    
    enum Constants {
        static let backgroundGray = UIColor(white: 0.0, alpha: 0.2)

        /// Delay before showing the spinner in case connection is restored or disconnected quickly
        static let reconnectionGraceTime: TimeInterval = 0.25

        /// Minimum time to show reconnection spinner
        static let reconnectionMinimumShowTime: TimeInterval = 0.75
    }
    
    static func showReconnectionHudAdded(to view: UIView, animated: Bool, didCancel: @escaping () -> ()) {
        let hud = MBProgressHUD()
        hud.graceTime = Constants.reconnectionGraceTime
        hud.minShowTime = Constants.reconnectionMinimumShowTime
        let reconnectionHudView = VisitReconnectionHudView()
        reconnectionHudView.didCancel = { () -> () in
            didCancel()
        }
        hud.backgroundView.style = .solidColor
        hud.backgroundView.color = Constants.backgroundGray
        hud.customView = reconnectionHudView
        hud.areDefaultMotionEffectsEnabled = false
        hud.bezelView.color = .clear
        hud.bezelView.style = .solidColor
        hud.mode = .customView
        hud.isUserInteractionEnabled = true
       
        view.addSubview(hud)
        hud.show(animated: animated)
    }
    
}
