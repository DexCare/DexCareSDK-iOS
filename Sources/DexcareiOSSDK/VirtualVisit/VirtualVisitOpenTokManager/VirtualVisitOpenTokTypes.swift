//
// VirtualVisitOpenTokProtocol.swift
// DexcareSDK
//
// Created by Reuben Lee on 2020-01-22.
// Copyright © 2020 Providence. All rights reserved.
//

import Foundation
import OpenTok

protocol SessionType {
    var sessionId: String { get }
    var connection: OTConnection? { get }
    var sessionConnectionStatus: OTSessionConnectionStatus { get }
    func connect(withToken token: String, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func disconnect(_ error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func signal(withType type: String?, string: String?, connection: OTConnection?, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func publish(publisher: PublisherType, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func unpublish(publisher: PublisherType, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func subscribe(subscriber: SubscriberType, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
    func unsubscribe(subscriber: SubscriberType, error: AutoreleasingUnsafeMutablePointer<OTError?>?)
}

extension OTSession: SessionType {
    func publish(publisher: PublisherType, error: AutoreleasingUnsafeMutablePointer<OTError?>?) {
        guard let publisher = publisher as? OTPublisher else {
            assertionFailure("Unable to get OTPublisher")
            return
        }
        publish(publisher, error: error)
    }
    
    func unpublish(publisher: PublisherType, error: AutoreleasingUnsafeMutablePointer<OTError?>?) {
        guard let publisher = publisher as? OTPublisher else {
            assertionFailure("Unable to get OTPublisher")
            return
        }
        unpublish(publisher, error: error)
    }
    
    func subscribe(subscriber: SubscriberType, error: AutoreleasingUnsafeMutablePointer<OTError?>?) {
        guard let subscriber = subscriber as? OTSubscriber else {
            assertionFailure("Unable to get OTSubscriber")
            return
        }
        subscribe(subscriber, error: error)
    }
    
    func unsubscribe(subscriber: SubscriberType, error: AutoreleasingUnsafeMutablePointer<OTError?>?) {
        guard let subscriber = subscriber as? OTSubscriber else {
            assertionFailure("Unable to get OTSubscriber")
            return
        }
        unsubscribe(subscriber, error: error)
    }
}

protocol PublisherType {
    var publishVideo: Bool { get set }
    var publishAudio: Bool { get set }
    var publishView: UIView? { get }
    var stream: OTStream? { get }
    var cameraCapturePosition: AVCaptureDevice.Position { get set }
    var networkStatsPublisherDelegate: NetworkStatsPublisherDelegate? { get set }
    var rtcStatsPublisherDelegate: RTCStatsPublisherDelegate? { get set }
    
    func getPublisherRTCStats()
}

// For the ease of mocking for the delegate calls which takes OTPublisherKit
// We need to manually convert OTPublisherKit back to OTPublisher to get the correct property
// If we need to use another OTPublisher property, make sure to add it with a different name. 
extension OTPublisherKit: PublisherType {
    var publishView: UIView? {
        if let publisher = self as? OTPublisher {
            return publisher.view
        }
        return UIView()
    }
    
    var cameraCapturePosition: AVCaptureDevice.Position {
        get {
            if let publisher = self as? OTPublisher {
                return publisher.cameraPosition
            }
            return .unspecified
        }
        set {
            if let publisher = self as? OTPublisher {
                publisher.cameraPosition = newValue
            }
        }
    }
    
    var networkStatsPublisherDelegate: NetworkStatsPublisherDelegate? {
        get {
            return self.networkStatsDelegate as? NetworkStatsPublisherDelegate
        }
        set {
            self.networkStatsDelegate = newValue
        }
    }
    
    var rtcStatsPublisherDelegate: RTCStatsPublisherDelegate? {
        get {
            return self.rtcStatsReportDelegate as? RTCStatsPublisherDelegate
        }
        set {
            self.rtcStatsReportDelegate = newValue
        }
    }
    
    func getPublisherRTCStats() {
        self.getRtcStatsReport()
    }
}

protocol SubscriberType {
    var subscriberView: UIView? { get }
    var preferredResolution: CGSize { get }
    var streamId: String? { get }
    var networkStatsSubscriberDelegate: NetworkStatsSubscriberDelegate? { get set }
    var rtcStatsSubscriberDelegate: RTCStatsSubscriberDelegate? { get set }
    
    func getSubscriberRTCStats()
}

extension OTSubscriberKit: SubscriberType {
    var subscriberView: UIView? {
        if let subscriber = self as? OTSubscriber {
            return subscriber.view
        }
        return UIView()
    }
    
    var streamId: String? {
        return self.stream?.streamId
    }
    
    var networkStatsSubscriberDelegate: NetworkStatsSubscriberDelegate? {
        get {
            return self.networkStatsDelegate as? NetworkStatsSubscriberDelegate
        }
        set {
            self.networkStatsDelegate = newValue
        }
    }
    
    var rtcStatsSubscriberDelegate: RTCStatsSubscriberDelegate? {
        get {
            return self.rtcStatsReportDelegate as? RTCStatsSubscriberDelegate
        }
        set {
            self.rtcStatsReportDelegate = newValue
        }
    }
    
    func getSubscriberRTCStats() {
        self.getRtcStatsReport()
    }
}

protocol SessionTypeDelegate: AnyObject {
    func sessionDidConnect(_ session: SessionType)
    func sessionDidDisconnect(_ session: SessionType)
    func session(_ session: SessionType, connectionCreated connection: OTConnection)
    func session(_ session: SessionType, connectionDestroyed connection: OTConnection)
    func session(_ session: SessionType, streamCreated stream: OTStream)
    func session(_ session: SessionType, streamDestroyed stream: OTStream)
    func session(_ session: SessionType, didFailWithError error: OTError)
    func sessionDidBeginReconnecting(_ session: SessionType)
    func sessionDidReconnect(_ session: SessionType)
    func session(_ session: SessionType, receivedSignalType type: String?, from connection: OTConnection?, with string: String?)
}

protocol PublisherTypeDelegate: AnyObject {
    func publisher(_ publisher: PublisherType, streamCreated stream: OTStream)
    func publisher(_ publisher: PublisherType, streamDestroyed stream: OTStream)
    func publisher(_ publisher: PublisherType, didFailWithError error: OTError)
}

protocol SubscriberTypeDelegate: AnyObject {
    func subscriberDidConnect(toStream subscriberKit: SubscriberType)
    func subscriberDidDisconnect(fromStream subscriber: SubscriberType)
    func subscriberVideoDisableWarning(_ subscriber: SubscriberType)
    func subscriberVideoDisableWarningLifted(_ subscriber: SubscriberType)
    func subscriberDidReconnect(toStream subscriber: SubscriberType)
    func subscriberVideoEnabled(_ subscriber: SubscriberType, reason: OTSubscriberVideoEventReason)
    func subscriberVideoDisabled(_ subscriber: SubscriberType, reason: OTSubscriberVideoEventReason)
    func subscriber(_ subscriber: SubscriberType, didFailWithError error: OTError)
}

extension OTConnection {
    var connectionData: ConnectionData? {
        guard
            let jsonData = data?.data(using: .utf8)
        else { return nil }
        
        return try? ConnectionData(jsonData: jsonData)
    }
}

protocol NetworkStatsSubscriberDelegate: OTSubscriberKitNetworkStatsDelegate {
    /**
     * Sent periodically to report audio statistics for the subscriber.
     *
     * @param subscriber The subscriber these statistic apply to.
     *
     * @param stats An <OTSubscriberKitVideoNetworkStats> object, which has
     * properties for the video bytes received, video packets lost, and video
     * packets received for the subscriber.
     */
    func subscriber(_ subscriber: SubscriberType, videoNetworkStatsUpdated stats: OTSubscriberKitVideoNetworkStats)
    
    /**
     * Sent periodically to report audio statistics for the subscriber.
     *
     * @param subscriber The subscriber these statistic apply to.
     *
     * @param stats An <OTSubscriberKitAudioNetworkStats> object, which has
     * properties for the audio bytes received, audio packets lost, and audio
     * packets received for the subscriber.
     */
    func subscriber(_ subscriber: SubscriberType, audioNetworkStatsUpdated stats: OTSubscriberKitAudioNetworkStats)
}

protocol NetworkStatsPublisherDelegate: OTPublisherKitNetworkStatsDelegate {
    /**
     * Sent periodically to report audio statistics for the publisher.
     *
     * @param publisher The publisher these statistic apply to.
     *
     * @param stats An <OTPublisherKitVideoNetworkStats> object, which has
     * properties for the video bytes received, video packets lost, and video
     * packets received for the publisher.
     */
    func publisher(_ publisher: PublisherType, videoNetworkStatsUpdated stats: [OTPublisherKitVideoNetworkStats])
    /**
     * Sent periodically to report audio statistics for the subscriber.
     *
     * @param publisher The publisher these statistic apply to.
     *
     * @param stats An <OTPublisherKitAudioNetworkStats> object, which has
     * properties for the audio bytes received, audio packets lost, and audio
     * packets received for the publisher.
     */
    func publisher(_ publisher: PublisherType, audioNetworkStatsUpdated stats: [OTPublisherKitAudioNetworkStats])
}

protocol RTCStatsPublisherDelegate: OTPublisherKitRtcStatsReportDelegate {
    func publisher(_ publisher: PublisherType, rtcStatsReport stats: [OTPublisherRtcStats])
}

protocol RTCStatsSubscriberDelegate: OTSubscriberKitRtcStatsReportDelegate {
    func subscriber(_ subscriber: SubscriberType, rtcStatsReport jsonArrayOfReports: String)
}

extension SessionType {
    func connect(token: String) throws {
        var error: OTError?
        connect(
            withToken: token,
            error: &error
        )
        
        if let error = error {
            throw error
        }
    }
    func disconnect() throws {
        var error: OTError?
        disconnect(
            &error
        )

        if let error = error {
            throw error
        }
    }
    func signal(type: String?, string: String?, connection: OTConnection?) throws {
        var error: OTError?
        signal(
            withType: type,
            string: string,
            connection: connection,
            error: &error
        )

        if let error = error {
            throw error
        }
    }
    func publish(publisher: PublisherType) throws {
        var error: OTError?
        publish(
            publisher: publisher,
            error: &error
        )

        if let error = error {
            throw error
        }
    
    }
    func unpublish(publisher: PublisherType) throws {
        var error: OTError?
        unpublish(
            publisher: publisher,
            error: &error
        )

        if let error = error {
            throw error
        }
    }
    func subscribe(subscriber: SubscriberType) throws {
        var error: OTError?
        subscribe(
            subscriber: subscriber,
            error: &error
        )

        if let error = error {
            throw error
        }
    }
    func unsubscribe(subscriber: SubscriberType) throws {
        var error: OTError?
        unsubscribe(
            subscriber: subscriber,
            error: &error
        )

        if let error = error {
            throw error
        }
    }
}
