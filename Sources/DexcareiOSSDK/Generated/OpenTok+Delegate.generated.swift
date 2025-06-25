// Generated using Sourcery 1.7.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable all
import OpenTok

extension VirtualVisitOpenTokManager: OTPublisherKitNetworkStatsDelegate {
    func publisher(_ publisher: OTPublisherKit, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats]) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, videoNetworkStatsUpdated: stats)
    }

    func publisher(_ publisher: OTPublisherKit, audioNetworkStatsUpdated stats: [OTPublisherKitAudioNetworkStats]) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, audioNetworkStatsUpdated: stats)
    }
}

extension VirtualVisitOpenTokManager: OTSubscriberKitNetworkStatsDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, videoNetworkStatsUpdated stats: OTSubscriberKitVideoNetworkStats) {
        let replacement: SubscriberType = subscriber
        self.subscriber(replacement, videoNetworkStatsUpdated: stats)
    }

    func subscriber(_ subscriber: OTSubscriberKit, audioNetworkStatsUpdated stats: OTSubscriberKitAudioNetworkStats) {
        let replacement: SubscriberType = subscriber
        self.subscriber(replacement, audioNetworkStatsUpdated: stats)
    }
}

extension VirtualVisitOpenTokManager: OTPublisherDelegate {
    func publisher(_ publisher: OTPublisherKit, streamCreated stream: OTStream) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, streamCreated: stream)
    }

    func publisher(_ publisher: OTPublisherKit, streamDestroyed stream: OTStream) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, streamDestroyed: stream)
    }

    func publisher(_ publisher: OTPublisherKit, didFailWithError error: OTError) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, didFailWithError: error)
    }
}

extension VirtualVisitOpenTokManager: OTPublisherKitRtcStatsReportDelegate {
    func publisher(_ publisher: OTPublisherKit, rtcStatsReport stats: [OTPublisherRtcStats]) {
        let replacement: PublisherType = publisher
        self.publisher(replacement, rtcStatsReport: stats)
    }
}

extension VirtualVisitOpenTokManager: OTSubscriberKitRtcStatsReportDelegate {
    func subscriber(_ subscriber: OTSubscriberKit, rtcStatsReport jsonArrayOfReports: String) {
        let replacement: SubscriberType = subscriber
        self.subscriber(replacement, rtcStatsReport: jsonArrayOfReports)
    }
}

extension VirtualVisitOpenTokManager: OTSessionDelegate {
    func sessionDidConnect(_ session: OTSession) {
        let replacement: SessionType = session
        self.sessionDidConnect(replacement)
    }

    func sessionDidDisconnect(_ session: OTSession) {
        let replacement: SessionType = session
        self.sessionDidDisconnect(replacement)
    }

    func session(_ session: OTSession, connectionCreated connection: OTConnection) {
        let replacement: SessionType = session
        self.session(replacement, connectionCreated: connection)
    }

    func session(_ session: OTSession, connectionDestroyed connection: OTConnection) {
        let replacement: SessionType = session
        self.session(replacement, connectionDestroyed: connection)
    }

    func session(_ session: OTSession, streamCreated stream: OTStream) {
        let replacement: SessionType = session
        self.session(replacement, streamCreated: stream)
    }

    func session(_ session: OTSession, streamDestroyed stream: OTStream) {
        let replacement: SessionType = session
        self.session(replacement, streamDestroyed: stream)
    }

    func session(_ session: OTSession, didFailWithError error: OTError) {
        let replacement: SessionType = session
        self.session(replacement, didFailWithError: error)
    }

    func sessionDidBeginReconnecting(_ session: OTSession) {
        let replacement: SessionType = session
        self.sessionDidBeginReconnecting(replacement)
    }

    func sessionDidReconnect(_ session: OTSession) {
        let replacement: SessionType = session
        self.sessionDidReconnect(replacement)
    }

    func session(_ session: OTSession, receivedSignalType type: String?, from connection: OTConnection?, with string: String?) {
        let replacement: SessionType = session
        self.session(replacement, receivedSignalType: type, from: connection, with: string)
    }
}

extension VirtualVisitOpenTokManager: OTSubscriberDelegate {
    func subscriberDidConnect(toStream subscriberKit: OTSubscriberKit) {
        let replacement: SubscriberType = subscriberKit
        self.subscriberDidConnect(toStream: replacement)
    }

    func subscriberDidDisconnect(fromStream subscriber: OTSubscriberKit) {
        let replacement: SubscriberType = subscriber
        self.subscriberDidDisconnect(fromStream: replacement)
    }

    func subscriberVideoDisableWarning(_ subscriber: OTSubscriberKit) {
        let replacement: SubscriberType = subscriber
        self.subscriberVideoDisableWarning(replacement)
    }

    func subscriberVideoDisableWarningLifted(_ subscriber: OTSubscriberKit) {
        let replacement: SubscriberType = subscriber
        self.subscriberVideoDisableWarningLifted(replacement)
    }

    func subscriberDidReconnect(toStream subscriber: OTSubscriberKit) {
        let replacement: SubscriberType = subscriber
        self.subscriberDidReconnect(toStream: replacement)
    }

    func subscriberVideoEnabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        let replacement: SubscriberType = subscriber
        self.subscriberVideoEnabled(replacement, reason: reason)
    }

    func subscriberVideoDisabled(_ subscriber: OTSubscriberKit, reason: OTSubscriberVideoEventReason) {
        let replacement: SubscriberType = subscriber
        self.subscriberVideoDisabled(replacement, reason: reason)
    }

    func subscriber(_ subscriber: OTSubscriberKit, didFailWithError error: OTError) {
        let replacement: SubscriberType = subscriber
        self.subscriber(replacement, didFailWithError: error)
    }
}
