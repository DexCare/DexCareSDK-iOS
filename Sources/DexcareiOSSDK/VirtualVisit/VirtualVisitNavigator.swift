// Copyright © 2019 DexCare. All rights reserved.

import Foundation
import MBProgressHUD
import SwiftUI
import UIKit

typealias PresentingCompletion = () -> Void

protocol VirtualVisitNavigatorType {
    func closeVisit()
    func reconnecting(didCancel: @escaping () -> Void)
    func reconnected()
    func showSurvey(request: URLRequest, onSurveyCompletion: PresentingCompletion?, completion: PresentingCompletion?) -> UIHostingController<SurveyWebView>?
    func showVisit(completion: PresentingCompletion?) -> VisitView?
    func showWaitingRoom(completion: PresentingCompletion?) -> WaitingRoomView?
    func showChat(manager: VirtualVisitManagerType, serverLogger: LoggingService?) -> ChatView?
    func showConvertToPhoneSuccessCTA(onClose: @escaping () -> Void, completion: PresentingCompletion?)
    func showWaitOfflineLanding(onCancel: @escaping () -> Void, onClose: @escaping () -> Void, completion: PresentingCompletion?)
    func displayAlert(title: String, message: String?, actions: [VirtualVisitAlertAction])
    func displayAlert(title: String, message: String?, actions: [VirtualVisitAlertAction], footer: VirtualVisitAlertFooter?)
    func displayCancelVisitAlert(title: String, message: String?, reasons: [CancelReason], didSelectReason: ((CancelReason) -> Void)?)
    func showHud()
    func hideHud()
}

class VirtualVisitNavigator: @preconcurrency VirtualVisitNavigatorType {
    var presentingViewController: UIViewController
    let customizationOptions: CustomizationOptions?

    var navigationController: UINavigationController?
    private var reconnectionHudController: UIViewController?

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

    @MainActor
    func closeVisit() {
        DispatchQueue.main.async {
            self.presentingViewController.dismiss(animated: true, completion: nil)
        }
    }

    @MainActor
    func reconnecting(didCancel: @escaping () -> Void) {
        let existingNavigationController = presentedNavigationController()

        if existingNavigationController.isViewControllerInStack(type: VisitHostingController.self) {
            existingNavigationController.pop(to: VisitHostingController.self, animated: false)
        } else if existingNavigationController.isViewControllerInStack(type: WaitingRoomHostingController.self) {
            existingNavigationController.pop(to: WaitingRoomHostingController.self, animated: false)
        }

        let reconnectionView = ReconnectionHudSwiftUIView(didCancel: { [weak self] in
            self?.reconnectionHudController?.dismiss(animated: true)
            self?.reconnectionHudController = nil
            didCancel()
        })
        let hostingController = UIHostingController(rootView: reconnectionView)
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        hostingController.view.backgroundColor = .clear
        reconnectionHudController = hostingController
        existingNavigationController.present(hostingController, animated: true)
    }

    @MainActor
    func reconnected() {
        reconnectionHudController?.dismiss(animated: true)
        reconnectionHudController = nil
    }

    @MainActor
    func showConvertToPhoneSuccessCTA(onClose: @escaping () -> Void, completion: PresentingCompletion?) {
        let existingNavigationController = presentedNavigationController(completion: completion)
        let waitOfflineLandingViewController = FullscreenCTAViewController(
            title: localizeString("dialog_convertToPhone_success_title"),
            message: localizeString("dialog_convertToPhone_success_message"),
            onActionString: nil,
            onAction: nil,
            onClose: onClose
        )
        existingNavigationController.setViewControllers([waitOfflineLandingViewController], animated: true)
    }

    @MainActor
    func showSurvey(request: URLRequest, onSurveyCompletion: PresentingCompletion?, completion: PresentingCompletion?) -> UIHostingController<SurveyWebView>? {
        let existingNavigationController = presentedNavigationController()

        // Check to see if we have shown the survey already
        guard !existingNavigationController.isViewControllerInStack(type: UIHostingController<SurveyWebView>.self) else {
            existingNavigationController.pop(to: UIHostingController<SurveyWebView>.self, animated: true)
            return existingNavigationController.viewControllers.last as? UIHostingController<SurveyWebView>
        }

        let surveyView = SurveyWebView(request: request) {
            onSurveyCompletion?()
        } didTapClose: {
            onSurveyCompletion?()
        }

        let surveyVC = UIHostingController(rootView: surveyView)
        existingNavigationController.pushViewController(surveyVC, animated: true)

        return surveyVC
    }

    @MainActor
    func showVisit(completion: PresentingCompletion?) -> VisitView? {
        let existingNavigationController = presentedNavigationController(completion: completion)

        // Check to see if we have shown the visit already
        guard !existingNavigationController.isViewControllerInStack(type: VisitHostingController.self) else {
            existingNavigationController.pop(to: VisitHostingController.self, animated: true)
            if let hostingController = existingNavigationController.viewControllers.last as? VisitHostingController {
                return hostingController.rootView.viewModel
            }
            return nil
        }

        let viewModel = VisitViewModel()
        let visitView = VisitSwiftUIView(viewModel: viewModel)
        let hostingController = VisitHostingController(rootView: visitView)
        existingNavigationController.pushViewController(hostingController, animated: true)
        return viewModel
    }

    @MainActor
    func showWaitingRoom(completion: PresentingCompletion?) -> WaitingRoomView? {
        let existingNavigationController = presentedNavigationController(completion: completion)

        // Check to see if we have shown the waiting room already
        guard !existingNavigationController.isViewControllerInStack(type: WaitingRoomHostingController.self) else {
            existingNavigationController.pop(to: WaitingRoomHostingController.self, animated: true)
            if let hostingController = existingNavigationController.viewControllers.last as? WaitingRoomHostingController {
                return hostingController.rootView.viewModel
            }
            return nil
        }

        let viewModel = WaitingRoomViewModel()
        viewModel.customizationOptions = customizationOptions
        let waitingRoomView = WaitingRoomSwiftUIView(viewModel: viewModel)
        let hostingController = WaitingRoomHostingController(rootView: waitingRoomView)
        existingNavigationController.setViewControllers([hostingController], animated: true)
        return viewModel
    }

    @MainActor
    func showChat(
        manager: VirtualVisitManagerType,
        serverLogger: LoggingService?
    ) -> ChatView? {
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

    @MainActor
    func showWaitOfflineLanding(
        onCancel: @escaping () -> Void,
        onClose: @escaping () -> Void,
        completion: PresentingCompletion?
    ) {
        let existingNavigationController = presentedNavigationController(completion: completion)
        let waitOfflineLandingViewController = FullscreenCTAViewController(
            title: localizeString("waitingRoom_waitOffline_title"),
            message: localizeString("waitingRoom_waitOffline_message"),
            onActionString: localizeString("waitingRoom_link_cancelVisit"),
            onAction: onCancel,
            onClose: onClose
        )
        existingNavigationController.setViewControllers([waitOfflineLandingViewController], animated: true)
    }

    @MainActor
    func displayAlert(title: String, message: String?, actions: [VirtualVisitAlertAction]) {
        displayAlert(title: title, message: message, actions: actions, footer: nil)
    }

    @MainActor
    func displayAlert(title: String, message: String?, actions: [VirtualVisitAlertAction], footer: VirtualVisitAlertFooter?) {
        let alertView = VirtualVisitAlertSwiftUIView(
            titleString: title,
            message: message,
            actions: actions,
            footer: footer,
            dismiss: { [weak self] in
                self?.navigationController?.presentedViewController?.dismiss(animated: true)
            }
        )
        let controller = UIHostingController(rootView: alertView)
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        controller.view.backgroundColor = .clear
        navigationController?.present(controller, animated: true, completion: nil)
    }

    @MainActor
    func displayCancelVisitAlert(title: String, message: String?, reasons: [CancelReason], didSelectReason: ((CancelReason) -> Void)?) {
        let controller = CancelVisitAlertViewController(reasons: reasons) { reason in
            didSelectReason?(reason)
        }

        navigationController?.present(controller, animated: true, completion: nil)
    }

    @MainActor
    func showHud() {
        guard let view = navigationController?.topViewController?.view else { return }
        MBProgressHUD.showAdded(to: view, animated: true)
    }

    @MainActor
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
