// Copyright © 2019 DexCare. All rights reserved.

import Foundation

/// The detail level of the logging
@frozen
public enum DexcareSDKLogLevel: Int {
    /// Log everything
    case verbose,
         /// helpful for developer debugging
         debug,
         /// general messages of events
         info,
         /// Something that is of concern
         warning,
         /// Something has gone wrong
         error
}

/// A Protocol to inherit from in order to see logging information that the DexCareSDK emits.
/**
 An example of a Logger that will log to the console. The DexCareSDK will use this logger calling the `log(message, level, sender)` function in this class with information.
 ~~~
 class ConsoleLogger: DexcareSDKLogger {

    static var shared: ConsoleLogger = ConsoleLogger()

    func log(_ message: String, level: DexcareSDKLogLevel, sender: String) {
        let emoji: String
        switch level {
            case .verbose: emoji = "➡️"
            case .debug: emoji = "✳️"
            case .info: emoji = "✏️"
            case .warning: emoji = "⚠️"
            case .error: emoji = "❌"
        }
        NSLog("\(emoji) \(sender): \(message)")
    }
 }
 ~~~

 This would show in the console as:
 ~~~
 ✳️ DexcareSDK: Response debug in 0.58s for: https://baseurl/v1/departments/epic.acme.one3511101000?byId=true&product=healthconnect-iOS - Status: 200 - Correlation: 16465A2F-69CE-4AF5-9FFA-827673AEF8F1
 ~~~
 The Correlation ID can help DexCare debug results.

 */
public protocol DexcareSDKLogger {
    /// The logging function
    func log(
        // sourcery: SaveParameters
        _ message: String,
        // sourcery: SaveParameters
        level: DexcareSDKLogLevel,
        sender: String
    )
}
// sourcery: AutoMockable
extension DexcareSDKLogger {
    // sourcery: NoMock
    func log(_ message: LogMessages, level: DexcareSDKLogLevel = .info, file: String = #file) {
        let filePath = (file as NSString).lastPathComponent.replacingOccurrences(of: "+", with: "_")
        log(message.rawValue, level: level, sender: "\((filePath as NSString).deletingPathExtension)")
    }

    // sourcery: NoMock
    func log(_ message: String, level: DexcareSDKLogLevel = .info, file: String = #file) {
        let filePath = (file as NSString).lastPathComponent.replacingOccurrences(of: "+", with: "_")
        log(message, level: level, sender: "\((filePath as NSString).deletingPathExtension)")
    }
}

enum LogMessages: String {
    case visitCancelled = "visit_cancelled"
    case visitFinished = "visit_finished"
    case visitLeft = "visit_left"
    case visitSessionBeginReconnecting = "visit_session_begin_reconnecting"
    case visitSessionDidReconnect = "visit_session_did_reconnect"
    case visitSessionDidFail = "visit_session_did_fail"
    case visitWaitingRoomSessionJoin = "visit_waiting_room_session_join"
    case visitVideoSessionJoin = "visit_video_session_join"
    case visitWaitingRoomRemoteTypingState = "visit_waiting_room_remote_typing_state"
    case visitWaitingRoomInstantMessageSent = "visit_waiting_room_instant_message_sent"
    case visitWaitingRoomInstantMessageReceived = "visit_waiting_room_instant_message_received"
    case visitWaitingRoomConnectionCreated = "visit_waiting_room_connection_created"
    case visitWaitingRoomConnectionDestroyed = "visit_waiting_room_connection_destroyed"
    case visitVideoRemoteTypingState = "visit_video_remote_typing_state"
    case visitVideoInstantMessageSent = "visit_video_instant_message_sent"
    case visitVideoInstantMessageReceived = "visit_video_instant_message_received"
    case visitVideoDidFail = "visit_video_did_fail"
    case visitVideoConnectionCreated = "visit_video_connection_created"
    case visitVideoConnectionDestroyed = "visit_video_connection_destroyed"
    case visitVideoStreamCreated = "visit_video_stream_created"
    case visitVideoStreamDestroyed = "visit_video_stream_destroyed"
    case visitVideoSubscriberDidDisconnect = "visit_video_subscriber_did_disconnect"
    case visitVideoSubscriberDidReconnect = "visit_video_subscriber_did_reconnect"
    case visitVideoSubscriberWarning = "visit_video_subscriber_warning"
    case visitVideoSubscriberWarningLifted = "visit_video_subscriber_warning_lifted"
}

extension LogMessages {
    func connectionId(_ connectionId: String) -> String {
        return self.rawValue + " > connectionId: \(connectionId)"
    }

    func sessionId(_ sessionId: String) -> String {
        return self.rawValue + " > sessionId: \(sessionId)"
    }

    func sessionId(_ sessionId: String, error: Error) -> String {
        return self.rawValue + " > sessionId: \(sessionId), error: \(String(describing: error))"
    }

    func reason(_ reason: VisitCompletionReason) -> String {
        return self.rawValue + " > reason: \(String(describing: reason))"
    }

    func error(_ error: Error) -> String {
        return self.rawValue + " > error: \(String(describing: error))"
    }

    func streamId(_ streamId: String) -> String {
        return self.rawValue + " > streamId: \(streamId)"
    }
}
