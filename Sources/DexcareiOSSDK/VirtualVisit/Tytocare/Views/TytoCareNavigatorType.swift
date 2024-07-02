import Foundation
import UIKit
import MBProgressHUD
import FittedSheets

protocol TytoCareNavigatorType {
    func showTytoCareSetup()
    func showPermissionView()
    func showWifiNameView()
    func showWifiPasswordView(includeWifiNameView: Bool)
    func showQRCodeView()
    
    func showHud()
    func hideHud()
    func displayAlert(title: String, message: String, actions: [VirtualVisitAlertAction])
    
    func closeView()
    func goBack(animated: Bool)
}

class TytoCareNavigator: TytoCareNavigatorType {
    var presentingViewController: UIViewController
    let storyboard = UIStoryboard(name: "TytoCare", bundle: .dexcareSDK)
    var navigationController: UINavigationController?
    var tytoCareManager: TytoCareManager
    
    init(presentingViewController: UIViewController, manager: TytoCareManager) {
        self.presentingViewController = presentingViewController
        self.tytoCareManager = manager
    }
    
    func showTytoCareSetup() {
       
        guard let tytoCareSetupViewController = storyboard.instantiateViewController(withIdentifier: "TytoCareSetupViewController") as? TytoCareSetupViewController else {
            fatalError("Unable to instantiate TytoCareSetupViewController from TytoCare storyboard in DexcareSDK.")
        }
            
        tytoCareSetupViewController.tytoCareManager = tytoCareManager
        let navController = UINavigationController(rootViewController: tytoCareSetupViewController)
        navController.setNavigationBarHidden(true, animated: false)
        
        let sheet = SheetViewController(
            controller: navController,
            sizes: [.fixed(650)], // hardcode height to fit qr code on the smallest device.
            options: SheetOptions(useInlineMode: true)) // show inline instead of modal
                
        sheet.animateIn(to: presentingViewController.view, in: presentingViewController)
        navigationController = navController
    }
    
    func showPermissionView() {
        guard let permissionViewController = storyboard.instantiateViewController(withIdentifier: "TytoCareMissingPrivacyViewController") as? TytoCareMissingPrivacyViewController else {
            fatalError("Unable to instantiate TytoCareMissingPrivacyViewController from TytoCare storyboard in DexcareSDK.")
        }
        permissionViewController.tytoCareManager = tytoCareManager
        navigationController?.pushViewController(permissionViewController, animated: true)
    }
    
    func showWifiNameView() {
        let wifiNameViewController = wifiNameView()
        navigationController?.pushViewController(wifiNameViewController, animated: true)
    }
    
    func showWifiPasswordView(includeWifiNameView: Bool) {
        
        guard let wifiPasswordViewController = storyboard.instantiateViewController(withIdentifier: "TytoCareWifiPasswordViewController") as? TytoCareWifiPasswordViewController else {
            fatalError("Unable to instantiate TytoCareWifiPasswordViewController from TytoCare storyboard in DexcareSDK.")
        }
        wifiPasswordViewController.tytoCareManager = tytoCareManager
        
        if includeWifiNameView {
            let wifiNameViewController = wifiNameView()
            let originalViewControllers = navigationController?.viewControllers
            
            var viewControllers = originalViewControllers ?? []
            viewControllers.append(wifiNameViewController)
            viewControllers.append(wifiPasswordViewController)
            
            navigationController?.setViewControllers(viewControllers, animated: true)
        } else {
            navigationController?.pushViewController(wifiPasswordViewController, animated: true)
        }
    }
    
    func showQRCodeView() {
        guard let qrCodeViewController = storyboard.instantiateViewController(withIdentifier: "TytoCareQRCodeViewController") as? TytoCareQRCodeViewController else {
            fatalError("Unable to instantiate TytoCareQRCodeViewController from TytoCare storyboard in DexcareSDK.")
        }
        qrCodeViewController.tytoCareManager = tytoCareManager
        navigationController?.pushViewController(qrCodeViewController, animated: true)
        
        tytoCareManager.virtualService?.virtualEventDelegate?.onDevicePairInitiated()
    }
    
    func showHud() {
        guard let view = navigationController?.topViewController?.view else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideHud() {
        guard let view = navigationController?.topViewController?.view else { return }
        MBProgressHUD.hide(for: view, animated: true)
    }
    
    func closeView() {
        guard let viewController = navigationController?.topViewController else { return }
        
        if viewController.sheetViewController?.options.useInlineMode == true {
            viewController.sheetViewController?.attemptDismiss(animated: true)
        } else {
            viewController.dismiss(animated: true, completion: nil)
        }
        navigationController = nil
    }
    
    func goBack(animated: Bool) {
        navigationController?.popViewController(animated: animated)
    }
    
    func displayAlert(title: String, message: String, actions: [VirtualVisitAlertAction]) {
        let controller = VirtualVisitAlertViewController(title: title, message: message, actions: actions)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    // Private
    func wifiNameView() -> TytoCareWifiNameViewController {
        guard let wifiNameViewController = storyboard.instantiateViewController(withIdentifier: "TytoCareWifiNameViewController") as? TytoCareWifiNameViewController else {
            fatalError("Unable to instantiate TytoCareSetupViewController from TytoCare storyboard in DexcareSDK.")
        }
        wifiNameViewController.tytoCareManager = tytoCareManager
        return wifiNameViewController
    }
}
