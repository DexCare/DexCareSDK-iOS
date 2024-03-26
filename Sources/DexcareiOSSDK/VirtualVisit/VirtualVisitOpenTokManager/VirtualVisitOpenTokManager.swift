// Copyright © 2019 Providence. All rights reserved.

import Foundation
import OpenTok

enum VisitSessionState: String, Equatable {
    case notStarted
    case waitingRoom
    case waitingRoomReconnecting
    case visit
    case visitReconnecting
    case failed
}

protocol VirtualVisitManagerType: AnyObject {
    var visitId: String { get }
    var userId: String { get }
    var chatDisplayName: String { get }
    
    var waitingRoomView: WaitingRoomView? { get }
    var virtualService: InternalVirtualService? { get }
    var waitTimeWorkItem: DispatchWorkItem? { get set }
    var inWaitingRoom: Bool { get }
    
    var networkStats: VideoCallStatistics? { get }
    
    func openChat()
    func toggleCamera()
    func toggleMic()
    func setUserIsTyping(_ isTyping: Bool)
    func sendChatMessage(_ message: String)
    func hangup()
    func cancel()
    func leave()
    func loadWaitTime()
    
    func toggleCameraPosition()
}

class VirtualVisitOpenTokManager: NSObject {
    let displayName: String
    let visitId: String
    let userId: String
    let apiKey: String
    let videoSessionId: String
    let waitingRoomSessionId: String
    let videoToken: String
    let waitingRoomToken: String
    var inVisitOnResume: Bool
    
    lazy var waitingRoomSession: SessionType? = OTSession(apiKey: apiKey, sessionId: waitingRoomSessionId, delegate: self)
    lazy var videoConferenceSession: SessionType? = OTSession(apiKey: apiKey, sessionId: videoSessionId, delegate: self)
    var videoSubscriber: SubscriberType?
    // This property is to address the issue where the video publisher was created when we where trying to clean it up.
    // This was a problem because creating the OTPublisher() take multiple seconds and was preventing the VirtualVisit
    // screen from being dismissed.
    private (set) var isVideoPublisherInstantiated: Bool = false
    lazy var videoPublisher: PublisherType = {
        let settings = OTPublisherSettings()
        let otPublisher = OTPublisher(delegate: self, settings: settings)!
        isVideoPublisherInstantiated = true
        return otPublisher
    }()
    lazy var subscriberFactory: SubscriberFactory = SubscriberFactory()
        
    let navigator: VirtualVisitNavigatorType
    let completion: VisitCompletion
    
    weak var virtualService: InternalVirtualService?
    lazy var permissionService: DevicePermissionService = DevicePermissionRequester()
    
    weak var waitingRoomView: WaitingRoomView?
    weak var visitView: VisitView?
    weak var chatView: ChatView?

    var waitTimeWorkItem: DispatchWorkItem?
    var statsWorkItem: DispatchWorkItem?
    
    var reconnectionWorkItem: DispatchWorkItem?
    let reconnectionTimeout: TimeInterval = 30.0
    
    var waitingRoomChatMessages: [ChatMessage] = []
    var videoChatMessages: [ChatMessage] = []
    var lastTypingState: Bool?

    var logger: DexcareSDKLogger?
    var serverLogger: LoggingService?
    var isReconnecting: Bool = false
    
    // retries every 1 second, for 120 seconds
    var failedMaximumRetry = 120
    var sessionWaitingRoomFailedCount = 0
    var sessionVideoFailedCount = 0
    var statsRefreshTime: TimeInterval = 10.0
    
    var visitState: VisitSessionState {
        guard
            let waitingRoomStatus = waitingRoomSession?.sessionConnectionStatus,
            let videoStatus = videoConferenceSession?.sessionConnectionStatus
        else { return .notStarted }
        
        if isReconnecting {
            return isPublishing ? .visitReconnecting : .waitingRoomReconnecting
        }
        
        let isOnVisitView = isPublishing || visitView != nil
        
        switch (waitingRoomStatus, videoStatus) {
        case (.failed, _), (_, .failed): return .failed
        case (_, .reconnecting) where isOnVisitView: return .visitReconnecting
        case (_, .connected) where isOnVisitView: return .visit
        case (.reconnecting, _) where !isOnVisitView: return .waitingRoomReconnecting
        case (.connected, _) where !isOnVisitView: return .waitingRoom
        default: return .notStarted
        }
    }
    
    var inWaitingRoom: Bool {
        return visitState == .waitingRoom || visitState == .waitingRoomReconnecting
    }
    
    var tytoCareManager: TytoCareManager?
    
    private enum Strings {
    
        static let openSettingsTitle = localizeString("dialog_permission_button_appSettings")

        // Visit EndCall
        static let hangupTitle = localizeString("dialog_visitEndConfirm_title")
        static let hangupMessage = localizeString("dialog_visitEndConfirm_message")
        static let hangupConfirm = localizeString("dialog_visitEndConfirm_button_confirm")
        static let hangupAbort = localizeString("dialog_visitEndConfirm_button_cancel")
        
        // Waiting Room Cancel
        static let cancelTitle = localizeString("dialog_waitingRoomCancelConfirm_title_cancelCall")
        static let cancelMessage = localizeString("dialog_waitingRoomCancelConfirm_message_cancelCallConfirmation")
        static let confirmAction = localizeString("dialog_waitingRoomCancelConfirm_button_confirm")
        static let cancelAbort = localizeString("dialog_waitingRoomCancelConfirm_button_cancel")
        
        // Waiting Room Leave
        static let leaveTitle = localizeString("dialog_waitingRoomCancelConfirm_title_leaveCall")
        static let leaveMessage = localizeString("dialog_waitingRoomCancelConfirm_message_leaveCallConfirmation")
        
        static let permissionTitle = localizeString("dialog_permission_title")
        static let permissionMessage = localizeString("dialog_permission_body_message")
        
        static let waitingRoomChatTitle = localizeString("waitingRoom_chatView_title_navigation")
        static let visitChatTitle = localizeString("visit_chatView_title_navigation")
        
        // Cancel Reconnect
        static let cancelReconnectTitle = localizeString("dialog_cancelReconnect_title")
        static let cancelReconnectMessage = localizeString("dialog_cancelReconnect_message")
        static let cancelReconnectCancel = localizeString("dialog_cancelReconnect_cancel")
        static let cancelReconnectKeepTrying = localizeString("dialog_cancelReconnect_confirm")
    }
    
    private enum Images {
        static var cameraEnabled: UIImage? = UIImage(named: "ic_white_videocam", in: .dexcareSDK, compatibleWith: nil)
        static var cameraDisabled: UIImage? = UIImage(named: "ic_white_videocam_off", in: .dexcareSDK, compatibleWith: nil)
        static var micEnabled: UIImage? = UIImage(named: "ic_white_mic", in: .dexcareSDK, compatibleWith: nil)
        static var micDisabled: UIImage? = UIImage(named: "ic_white_mic_off", in: .dexcareSDK, compatibleWith: nil)
    }
    
    var networkStats: VideoCallStatistics?
    
    init(
        virtualService: InternalVirtualService,
        displayName: String,
        visitId: String,
        userId: String,
        apiKey: String,
        waitingRoomSessionId: String,
        videoSessionId: String,
        waitingRoomToken: String,
        videoToken: String,
        inVisitOnResume: Bool,
        navigator: VirtualVisitNavigatorType,
        customization: CustomizationOptions?,
        tytoCare: TytoCareResponse,
        logger: DexcareSDKLogger?,
        serverLogger: LoggingService?,
        completion: @escaping VisitCompletion
    ) {
        self.virtualService = virtualService
        self.displayName = displayName
        self.visitId = visitId
        self.userId = userId
        self.apiKey = apiKey
        self.waitingRoomSessionId = waitingRoomSessionId
        self.videoSessionId = videoSessionId
        self.waitingRoomToken = waitingRoomToken
        self.videoToken = videoToken
        self.inVisitOnResume = inVisitOnResume
        self.navigator = navigator
        self.completion = completion
        self.logger = logger
        self.serverLogger = serverLogger
        
        networkStats = VideoCallStatistics()
        
        super.init()
                
        // server has the integration turned on.
        if tytoCare.enabled {
            setupTytoCareManager(tytoCareConfig: customization?.tytoCareConfig ?? TytoCareConfig(helpURL: nil), logger: logger)
        }
        
        joinConference()
    }
    
    func setupTytoCareManager(tytoCareConfig: TytoCareConfig, logger: DexcareSDKLogger?) {
        self.tytoCareManager = TytoCareManager(visitId: self.visitId, tytoCareConfig: tytoCareConfig, logger: logger, virtualService: self.virtualService)
    }
    
    func joinConference() {
        do {
            try waitingRoomSession?.connect(token: waitingRoomToken)
        } catch {
            self.processError(error: error, isFatal: true, message: "Unable to connect to waiting room session")
        }
        
        do {
            try videoConferenceSession?.connect(token: videoToken)
        } catch {
            self.processError(error: error, isFatal: true, message: "Unable to connect to visit session")
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    func endConference(reason: VisitCompletionReason) {
        
        // Log video and audio stats, for publisher and subscriber
        var stats = networkStats.toDictionary()
        stats["VisitCompletionReason"] = reason.rawValue as AnyObject
        
        serverLogger?.postMessage(message: "Video Visit Network Stats", data: LoggingRequest.toStringDictionary(dict: stats))
                
        logger?.log(LogMessages.visitFinished.reason(reason))
        self.virtualService?.virtualEventDelegate?.onVirtualVisitCompleted(reason: reason)
        self.virtualService?.currentVirtualEndTime = Date()
        
        defer {
            navigator.closeVisit()
            completion(reason)
            // Remove reference
            virtualService?.virtualVisitManager = nil
            isReconnecting = false
            stopStatsCollection()
            NotificationCenter.default.removeObserver(self)
        }
        
        guard
            let waitingRoomSession = waitingRoomSession,
            let videoConferenceSession = videoConferenceSession
        else {
            return
        }
        
        try? cleanupPublisher()
        try? cleanupSubscriber()
        
        try? waitingRoomSession.disconnect()
        try? videoConferenceSession.disconnect()
    }
    
    @objc func applicationWillEnterForeground() {
        Task {
            let permissions = await permissionService.requestPermissions(withVisitType: .virtual)
            if !permissions.granted {
                self.showPermissionDeniedAlert()
            }
            
            // If we are in waiting room, force a refresh of the wait time
            switch self.visitState {
            case .waitingRoom, .waitingRoomReconnecting:
                self.cancelWaitTimeWorkItem()
                self.updateWaitTime()
            default: break
            }
            
            self.serverLogger?.postMessage(message: "applicationWillEnterForeground", data: ["visitState": visitState.rawValue])
        }
        
    }
    
    @objc func applicationDidEnterBackground() {
        switch visitState {
        case .waitingRoom, .waitingRoomReconnecting:
            cancelWaitTimeWorkItem()
        default: break
        }
        
        serverLogger?.postMessage(message: "applicationDidEnterBackground", data: ["visitState": visitState.rawValue])
    }
    
    func showPermissionDeniedAlert() {
        self.navigator.displayAlert(
            title: Strings.permissionTitle,
            message: Strings.permissionMessage,
            actions: [
                AlertAction(title: Strings.confirmAction, style: .destructive, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    Task {
                        try await strongSelf.virtualService?.cancelVirtualVisit(visitId: strongSelf.visitId)
                    }
                    strongSelf.endConference(reason: .canceled)
                }),
                AlertAction(title: Strings.openSettingsTitle, style: .cancel, handler: { _ in
                    guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                        return
                    }
                    UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
                })
            ]
        )
    }
    
    var isPublishing: Bool = false
    
    func processError(error: Error, isFatal: Bool, message: String) {
        if isFatal {
            logger?.log("OpenTok Fatal Error: \(message) - \(error)", level: .error)
            self.serverLogger?.postMessage(message: "OpenTok FATAL error: \(message) - \(String(describing: error))")
            
            virtualService?.onVisitFailure(reason: VirtualVisitFailedReason.from(error: error))
            endConference(reason: VisitCompletionReason.from(error: error))
        } else {
            logger?.log("OpenTok Error: \(message) - \(error)", level: .error)
            self.serverLogger?.postMessage(message: "OpenTok error: \(message) - \(String(describing: error))")
            
            virtualService?.virtualEventDelegate?.onVirtualVisitError(error: isPublishing ? .virtualVisitOpenTokError(error) : .waitingRoomOpenTokError(error))
        }
    }
}

// MARK: - VirtualVisitManagerType
extension VirtualVisitOpenTokManager: VirtualVisitManagerType {
    var chatMessages: [ChatMessage] {
        switch visitState {
        case .visit:
            return videoChatMessages
        case .waitingRoom:
            return waitingRoomChatMessages
        default: return []
        }
    }
    
    var chatDisplayName: String {
        return displayName
    }

    func openChat() {
        switch visitState {
        case .visit:
            if chatView == nil {
                chatView = navigator.showChat(manager: self, serverLogger: serverLogger)
            }
            chatView?.navigationTitle = Strings.visitChatTitle
            chatView?.refresh(chatMessages: chatMessages)
        case .waitingRoom:
            if chatView == nil {
                chatView = navigator.showChat(manager: self, serverLogger: serverLogger)
            }
            chatView?.navigationTitle = Strings.waitingRoomChatTitle
            chatView?.refresh(chatMessages: chatMessages)
        default: break
        }
    }
    
    func setCamIsEnabled(_ enabled: Bool) {
        videoPublisher.publishVideo = enabled
    }
    
    func setMicIsEnabled(_ enabled: Bool) {
        videoPublisher.publishAudio = enabled
    }

    func toggleCamera() {
        videoPublisher.publishVideo = !videoPublisher.publishVideo
        visitView?.cameraButtonImage = videoPublisher.publishVideo ? Images.cameraEnabled : Images.cameraDisabled
    }
    
    func toggleMic() {
        videoPublisher.publishAudio = !videoPublisher.publishAudio
        visitView?.micButtonImage = videoPublisher.publishAudio ? Images.micEnabled : Images.micDisabled
    }
    
    func setUserIsTyping(_ isTyping: Bool) {
        guard isTyping != lastTypingState else { return }
        
        let json: String?
        do {
            let message = RemoteTypingStateMessage(displayName: displayName, typingState: isTyping ? 1 : 0)
            json = try message.toJSON()
        } catch {
            assertionFailure("unable to send typing state to session. \(String(describing: error))")
            return
        }

        switch visitState {
        case .visit:
            do {
                try videoConferenceSession?.signal(type: SignalMessageType.typingStateMessage.rawValue, string: json, connection: nil)
            } catch {
                self.processError(error: error, isFatal: false, message: "Unable to send visit typing state")
            }
            
        case .waitingRoom:
       
            do {
                try waitingRoomSession?.signal(type: SignalMessageType.typingStateMessage.rawValue, string: json, connection: nil)
            } catch {
                self.processError(error: error, isFatal: false, message: "Unable to send waiting room typing state")
            }
        
        default: break
        }
        
        lastTypingState = isTyping
    }
    
    func sendChatMessage(_ message: String) {        
        let instantMessage = SignalInstantMessage(
            fromParticipant: displayName,
            senderId: userId,
            creationTime: Date(),
            uniqueId: UUID().uuidString,
            message: message,
            isStaff: nil
        )
        
        let json: String?
        do {
            json = try instantMessage.toJSON()
        } catch {
            assertionFailure("unable to send typing state to session. \(String(describing: error))")
            return
        }

        switch visitState {
        case .visit:
         
            do {
                try videoConferenceSession?.signal(type: SignalMessageType.instantMessage.rawValue, string: json, connection: nil)
            } catch {
                self.processError(error: error, isFatal: false, message: "Unable to send visit instant message")
            }
            
            postChatMessage(sessionId: videoSessionId, instantMessage: instantMessage)
            logger?.log(.visitVideoInstantMessageSent)
        case .waitingRoom:
       
            do {
                try waitingRoomSession?.signal(type: SignalMessageType.instantMessage.rawValue, string: json, connection: nil)
            } catch {
                self.processError(error: error, isFatal: false, message: "Unable to send waiting room instant message")
            }
            
            logger?.log(.visitWaitingRoomInstantMessageSent)
            postChatMessage(sessionId: waitingRoomSessionId, instantMessage: instantMessage)
           
        default: break
        }
    }
 
    private func postChatMessage(sessionId: String, instantMessage: SignalInstantMessage) {
        // Post the message to lion tower for chat persistence
        
        guard let virtualService = self.virtualService else {
            return
        }
        
        Task {
            do {
                try await virtualService.postChatMessage(visitId: visitId, sessionId: sessionId, message: instantMessage)
            } catch {
                self.logger?.log("Error posting waiting room chat message: \(error)", level: .error)
            }
        }
    }
    
    func hangup() {
        navigator.displayAlert(
            title: Strings.hangupTitle,
            message: Strings.hangupMessage,
            actions: [
                AlertAction(title: Strings.hangupConfirm, style: .default, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                
                    do {
                        try strongSelf.waitingRoomSession?.signal(type: SignalMessageType.participantLeft.rawValue, string: nil, connection: nil)
                        try strongSelf.videoConferenceSession?.signal(type: SignalMessageType.participantLeft.rawValue, string: nil, connection: nil)
                        strongSelf.endConference(reason: .completed)
                        
                    } catch {
                        // don't care about any errors here
                    }
                    
                }),
                AlertAction(title: Strings.hangupAbort, style: .cancel, handler: nil)
            ]
        )
    }
    
    func cancel() {
        navigator.displayAlert(
            title: Strings.cancelTitle,
            message: Strings.cancelMessage,
            actions: [
                AlertAction(title: Strings.confirmAction, style: .destructive, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.navigator.showHud()
                    Task {
                        do {
                            try await strongSelf.virtualService?.cancelVirtualVisit(visitId: strongSelf.visitId)
                        } catch {
                            // we aren't handling errors
                        }
                    }
                    strongSelf.navigator.hideHud()
                    strongSelf.logger?.log(.visitCancelled)
                    strongSelf.virtualService?.virtualEventDelegate?.onVirtualVisitCancelledByUser()
                    strongSelf.endConference(reason: .canceled)
                }),
                AlertAction(title: Strings.cancelAbort, style: .cancel, handler: nil)
            ]
        )
    }
    
    func leave() {
        navigator.displayAlert(
            title: Strings.leaveTitle,
            message: Strings.leaveMessage,
            actions: [
                AlertAction(title: Strings.confirmAction, style: .destructive, handler: { [weak self] _ in
                    self?.navigator.showHud()
                    try? self?.waitingRoomSession?.signal(type: SignalMessageType.participantLeft.rawValue, string: nil, connection: nil)
                    self?.navigator.hideHud()
                    self?.logger?.log(.visitLeft)
                    self?.virtualService?.virtualEventDelegate?.onVirtualVisitCancelledByUser()
                    self?.endConference(reason: .left)
                }),
                AlertAction(title: Strings.cancelAbort, style: .cancel, handler: nil)
            ]
        )
    }
    
    func cancelReconnectionAlert() {
        navigator.displayAlert(
            title: Strings.cancelReconnectTitle,
            message: Strings.cancelReconnectMessage,
            actions: [
                AlertAction(title: Strings.cancelReconnectCancel, style: .destructive, handler: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.cancelReconnectionWorkItem()
                    strongSelf.endConference(reason: .exceededReconnectAttempt)
                }),
                AlertAction(title: Strings.cancelReconnectKeepTrying, style: .cancel, handler: nil)
            ]
        )
    }
    
    func toggleCameraPosition() {
        if videoPublisher.cameraCapturePosition == .front {
            videoPublisher.cameraCapturePosition = .back
        } else {
            videoPublisher.cameraCapturePosition = .front
        }
    }
}

// MARK: - Publishing
extension VirtualVisitOpenTokManager {
    func openVideoVisit() {
        guard let subscriber = videoSubscriber else {
            assertionFailure("We are opening video visit without a video subscriber")
            return
        }
        
        waitingRoomCleanup()
        navigateToVisitView()
        setupLocalAndRemoteView(subscriber: subscriber)
        
        startStatsCollection()
    }
    
    private func waitingRoomCleanup() {
        // Tokbox publishing sometimes create some artifacts on the preview screen
        // Make sure to stop it before we transition to the visit view
        waitingRoomView?.stopSelfPreview()
        cancelWaitTimeWorkItem()
    }
    
    private func setupLocalAndRemoteView(subscriber: SubscriberType) {
        if !isPublishing {
            do {
                try videoConferenceSession?.publish(publisher: videoPublisher)
            } catch {
                self.processError(error: error, isFatal: true, message: "Unable to publish video stream to visit session")
            }
        }
        
        guard let remoteView = subscriber.subscriberView, let localView = videoPublisher.publishView else {
            assertionFailure("Opening video visit and unable to get local and remote UIViews")
            return
        }
        
        visitView?.removeLocalView()
        visitView?.addLocalView(localView, resolutionSize: videoPublisher.stream?.videoDimensions ?? CGSize(width: 0, height: 0))
        visitView?.removeRemoteView()
        visitView?.addRemoteView(remoteView, resolutionSize: subscriber.preferredResolution)
        
        logger?.log("openVideoVisit adding local and remote views", level: .verbose)
    }
    
    func cleanupPublisher() throws {
        visitView?.removeLocalView()
        guard let videoConferenceSession = videoConferenceSession else { return }
        if isVideoPublisherInstantiated {
            try videoConferenceSession.unpublish(publisher: videoPublisher)
        }
    }
    
    func navigateToVisitView() {
        setCamIsEnabled(true)
        setMicIsEnabled(true)
        
        if visitView == nil {
            visitView = navigator.showVisit { [weak self] in
                guard let self else { return }
                self.virtualService?.onVisitSuccess(visitId: self.visitId)
                
            }
            visitView?.manager = self
            visitView?.showCameraPositionToggle = true
            visitView?.tytoCareManager = tytoCareManager
            
        }
        virtualService?.virtualEventDelegate?.onVirtualVisitStarted()
    }
}

// MARK: - Subscribing
extension VirtualVisitOpenTokManager {
    func cleanupSubscriber() throws {
        visitView?.removeRemoteView()
        guard
            let subscriber = videoSubscriber,
            let videoConferenceSession = videoConferenceSession
        else { return }
        
        defer {
            self.videoSubscriber = nil
            self.logger?.log("cleanupSubscriber: clear videoSubscriber", level: .verbose)
        }
        
        return try videoConferenceSession.unsubscribe(subscriber: subscriber)
    }
}

// MARK: - Error
extension VirtualVisitOpenTokManager {
    private func cancelReconnectionWorkItem() {
        reconnectionWorkItem?.cancel()
        reconnectionWorkItem = nil
    }
    
    func reconnecting(timeout: Bool = true) {
        isReconnecting = true
        navigator.reconnecting(didCancel: { [weak self] in
            // Prompt user to cancel
            self?.cancelReconnectionAlert()
        })
        
        // Cancel any existing workItem if there is any
        if reconnectionWorkItem != nil {
            cancelReconnectionWorkItem()
        }
        
        guard timeout else { return }
        
        // Dispatch the work item based on wall time
        let workItem = DispatchWorkItem { [weak self] in
            self?.endConference(reason: .exceededReconnectAttempt)
        }
        reconnectionWorkItem = workItem
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + reconnectionTimeout, execute: workItem)
    }
    
    func reconnected() {
        isReconnecting = false
        navigator.reconnected()
        cancelReconnectionWorkItem()
    }
}

// MARK: - Error
extension VisitCompletionReason {
    static func from(error: Error) -> VisitCompletionReason {
        guard
            let sessionErrorCode = error.asOTSessionErrorCode
        else {
            return .failed
        }
        
        switch sessionErrorCode {
        case .OTErrorInvalidSession: return .conferenceNonExistent
        case .OTConnectionFailed: return .networkIssues
        case .OTNotConnected: return .conferenceInactive
        case .OTP2PSessionMaxParticipants: return .conferenceFull
        case .OTSessionConnectionTimeout: return .exceededReconnectAttempt
        case .OTConnectionDropped: return .exceededReconnectAttempt
        default: return .failed
        }
    }
}

extension Error {
    var asOTSessionErrorCode: OTSessionErrorCode? {
        let nsError = self as NSError
        
        guard
            let sessionErrorCode = OTSessionErrorCode(rawValue: Int32(nsError.code))
        else {
            return nil
        }
        
        return sessionErrorCode
    }
}
