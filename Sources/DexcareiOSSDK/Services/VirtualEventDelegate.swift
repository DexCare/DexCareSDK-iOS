/// When set on the VirtualService, the delegate will invoke various events allowing you to capture analytics.
/// - Important: all functions returned here for only for analytic purposes. Any errors returned in `onVirtualVisitError` are "soft" errors - meaning the virtual visit will still be running.
/// - Note: All "hard" failures, should be caught inside the `failure` closure when starting or resume a virtual visit.
public protocol VirtualEventDelegate: AnyObject {
    /// Called when the virtual visit waiting room is first displayed to the user.
    func onWaitingRoomLaunched()
    
    /// Called when the waiting room session is disconnected. SDK will return as a failure in the main closure
    func onWaitingRoomDisconnected()
    /// Called when the SDK attempts to reconnect to the waiting room session
    func onWaitingRoomReconnecting()
    /// Called when the SDK successfully reconnects to the waiting room session
    func onWaitingRoomReconnected()
    
    /// Called when the virtual visit session is disconnected. SDK will return as a failure in the main closure
    func onVirtualVisitDisconnected()
    /// Called when the SDK attempts to reconnect to the virtual visit session
    func onVirtualVisitReconnecting()
    /// Called when the SDK successfully reconnects to the virtual visit session
    func onVirtualVisitReconnected()
    /// Called when the Provider connects to the patient's session and starts the visit.
    func onVirtualVisitStarted()
    /// Called when the visit is closed (successfully or not). See `VisitCompletionReason`
    func onVirtualVisitCompleted(reason: VisitCompletionReason)
    
    /// Called when the user cancelled the visit from the waiting room.
    func onVirtualVisitCancelledByUser()
    /// Called when the provider declines to see the patient.
    /// - Note: Patients are not charged for incomplete visits
    func onVirtualVisitDeclinedByProvider()
    /// Called when something went wrong inside the virtual visit.
    /// - Note: This does not mean that the visit failed or cannot continue.
    func onVirtualVisitError(error: VirtualVisitEventError)
    /// Called when a device pairing is initiated.
    /// Currently, TytoCare is the only supported integration.
    /// - Note: This callback is invoked when the QR code is generated and displayed to the user.
    func onDevicePairInitiated()
}

/// Various errors that can happen during a virtual visit session.
/// - Note: These should be used for logging purposes only. Any fatal errors will return in the failure closure when starting or resuming a visit.
public enum VirtualVisitEventError: Error, Equatable {
    public static func == (lhs: VirtualVisitEventError, rhs: VirtualVisitEventError) -> Bool {
        String(reflecting: lhs) == String(reflecting: rhs)
    }
    /// The TokBox (aka OpenTok, aka Vonage) SDK encountered an error in the waiting room.
    case waitingRoomOpenTokError(Error)
    /// The TokBox (aka OpenTok, aka Vonage) SDK encountered an error in the video conference
    case virtualVisitOpenTokError(Error)
    /// A device failed to pair.
    /// Currently, TytoCare is the only supported integration.
    case devicePairError(DevicePairError)
}

/// Various errors that can happen during the pairing of a external device.
public enum DevicePairError: Error, Equatable {
    public static func == (lhs: DevicePairError, rhs: DevicePairError) -> Bool {
        String(reflecting: lhs) == String(reflecting: rhs)
    }
    
    /// A TytoCare device failed to pair.
    /// - Note: This is returned when the TytoCare account creation or device pairing fails.
    case tytoCarePairFailed(TytoCareFailedReason)
}
