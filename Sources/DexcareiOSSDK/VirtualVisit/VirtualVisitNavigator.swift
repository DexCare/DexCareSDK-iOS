// Copyright © 2019 Providence. All rights reserved.

import Foundation
import MBProgressHUD
import UIKit

typealias AlertActionHandler = (UIAlertAction) -> Void
typealias PresentingCompletion = () -> Void

struct AlertAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: AlertActionHandler?
}

protocol VirtualVisitNavigatorType {
    func closeVisit()
    func reconnecting(didCancel: @escaping () -> ())
    func reconnected()
    func showVisit(completion: PresentingCompletion?) -> VisitView?
    func showWaitingRoom(completion: PresentingCompletion?) -> WaitingRoomView?
    func showChat(manager: VirtualVisitManagerType, serverLogger: LoggingService?) -> ChatView?
    func displayAlert(title: String, message: String, actions: [AlertAction])
    func showHud()
    func hideHud()
}

class VirtualVisitNavigator: VirtualVisitNavigatorType {
    var presentingViewController: UIViewController
    let customizationOptions: CustomizationOptions?
    
    let storyboard = UIStoryboard(name: "DexcareVirtualVisit", bundle: .dexcareSDK)
    var navigationController: UINavigationController?
    
    init(presentingViewController: UIViewController, customizationOptions: CustomizationOptions?) {
        self.presentingViewController = presentingViewController
        self.customizationOptions = customizationOptions
    }
    
    private func presentedNavigationController(completion: PresentingCompletion? = nil) -> UINavigationController {
        if let navigationController = navigationController {
            return navigationController
        } else {
            let newNavigationController = UINavigationController()
    
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            
            // Set background color of nav bar:
            // appearance.backgroundColor = UIColor.green
            
            newNavigationController.navigationBar.scrollEdgeAppearance = appearance
            newNavigationController.navigationBar.compactAppearance = appearance
            newNavigationController.navigationBar.standardAppearance = appearance
            
            if #available(iOS 15, *) {
                newNavigationController.navigationBar.compactScrollEdgeAppearance = appearance
            }
            
            newNavigationController.modalPresentationStyle = .fullScreen
            self.presentingViewController.present(newNavigationController, animated: false, completion: completion)
            self.navigationController = newNavigationController
            return newNavigationController
        }
    }
    
    func closeVisit() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
    
    func reconnecting(didCancel: @escaping () -> ()) {
        let existingNavigationController = presentedNavigationController()
        
        if existingNavigationController.isViewControllerInStack(type: VisitViewController.self) {
            existingNavigationController.pop(to: VisitViewController.self, animated: false)
        } else if existingNavigationController.isViewControllerInStack(type: WaitingRoomViewController.self) {
            existingNavigationController.pop(to: WaitingRoomViewController.self, animated: false)
        }
        
        existingNavigationController.topViewController?.updateHUD(desiredVisibility: .shouldBeVisible, didCancel: didCancel)
    }
    
    func reconnected() {
        presentedNavigationController().topViewController?.updateHUD(desiredVisibility: .shouldNotBeVisible, didCancel: {
            // Nothing to do if cancelled
        })
    }
    
    func showVisit(completion: PresentingCompletion?) -> VisitView? {
        let existingNavigationController = presentedNavigationController(completion: completion)
        
        // Check to see if we have shown the waiting room already
        guard !existingNavigationController.isViewControllerInStack(type: VisitViewController.self) else {
            existingNavigationController.pop(to: VisitViewController.self, animated: true)
            return existingNavigationController.viewControllers.last as? VisitViewController
        }
        
        // Get the view controller from the storyboard
        guard let visitViewController = storyboard.instantiateViewController(withIdentifier: "VisitViewController") as? VisitViewController else {
            fatalError("Unable to instantiate VisitViewController from Virtual Visit storyboard in DexcareSDK.")
        }
        
        // Because we are setting the stream right away, we need to make sure the view is loaded
        visitViewController.loadViewIfNeeded()
        existingNavigationController.pushViewController(visitViewController, animated: true)
        return visitViewController
    }
    
    func showWaitingRoom(completion: PresentingCompletion?) -> WaitingRoomView? {
        let existingNavigationController = presentedNavigationController(completion: completion)
        
        // Check to see if we have shown the waiting room already
        guard !existingNavigationController.isViewControllerInStack(type: WaitingRoomViewController.self) else {
            existingNavigationController.pop(to: WaitingRoomViewController.self, animated: true)
            return existingNavigationController.viewControllers.last as? WaitingRoomViewController
        }
        
        // Get the view controller from the storyboard
        guard let waitingRoomViewController = storyboard.instantiateViewController(withIdentifier: "WaitingRoomViewController") as? WaitingRoomViewController else {
            fatalError("Unable to instantiate WaitingRoomViewController from Virtual Visit storyboard in DexcareSDK.")
        }
        waitingRoomViewController.customizationOptions = customizationOptions
        
        existingNavigationController.setViewControllers([waitingRoomViewController], animated: true)
        return waitingRoomViewController
    }
    
    func showChat(manager: VirtualVisitManagerType,
                  serverLogger: LoggingService?) -> ChatView? {
        let existingNavigationController = presentedNavigationController()
        
        // Check to see if we have shown the chat already
        guard !existingNavigationController.isViewControllerInStack(type: ChatViewController.self) else {
            existingNavigationController.pop(to: ChatViewController.self, animated: true)
            return existingNavigationController.viewControllers.last as? ChatViewController
        }
        
        let chatViewController = ChatViewController(manager: manager, serverLogger: serverLogger)
        existingNavigationController.pushViewController(chatViewController, animated: true)
        return chatViewController
    }
    
    func displayAlert(title: String, message: String, actions: [AlertAction]) {
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        actions.forEach { action in
            controller.addAction(UIAlertAction(title: action.title, style: action.style, handler: action.handler))
        }
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    func showHud() {
        guard let view = navigationController?.topViewController?.view else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
    }
    
    func hideHud() {
        guard let view = navigationController?.topViewController?.view else { return }
        MBProgressHUD.hide(for: view, animated: true)
    }
}

extension UINavigationController {
    func isViewControllerInStack(type: UIViewController.Type) -> Bool {
        return self.viewControllers.contains(where: { $0.isKind(of: type) })
    }
    
    func pop(to viewControllerClass: UIViewController.Type, animated: Bool) {
        var newViewControllers = viewControllers
        while let lastViewController = newViewControllers.last, type(of: lastViewController) != viewControllerClass {
            newViewControllers.removeLast()
        }
        setViewControllers(newViewControllers, animated: animated)
    }
}
