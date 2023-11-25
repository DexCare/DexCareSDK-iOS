import Foundation
import OpenTok

// how often we are saving the stats back to memory
internal var TIMEWINDOW: Double = 3000

/// Contains any collected statistics from a Virtual Visit session.
/// The data will only be populated when after a virtual visit conference has occurred in the current SDK session. This data is only persisted in memory.
public struct VideoCallStatistics: Encodable {
   
    /// Statistics about received video
    public var subscriberVideoStats: SubscriberNetworkStats
    /// Statistics about received audio
    public var subscriberAudioStats: SubscriberNetworkStats
    
    /// Statistics about when you publish a video. ie have your camera on and a provider is watching
    public var publisherVideoStats: [PublisherNetworkStats]
    /// Statistics about when you publish your microphone and the provider is listening
    public var publisherAudioStats: [PublisherNetworkStats]
    
    /// Contains Real Time Communication stats about the publisher (patient).
    /// - Note: See https://tokbox.com/developer/sdks/android/reference/com/opentok/android/SubscriberKit.SubscriberRtcStatsReportListener.html
    public var publisherRTCStats: [PublisherRtcStats]
    /// Statistics when in real time communication and you're listening to a session
    /// - Note: See `PublisherRtcStats.jsonArrayOfReports` for more info
    public var subscriberRTCStats: String
    
    // Default init
    public init() {
        subscriberVideoStats = SubscriberNetworkStats()
        subscriberAudioStats = SubscriberNetworkStats()
        publisherVideoStats = []
        publisherAudioStats = []
        
        publisherRTCStats = []
        subscriberRTCStats = ""
    }
}

/// Statistics when in real time communication and you're publishing a video to a session
public struct PublisherRtcStats: Encodable {
    /// The connectionId these stats belong to
    public var connectionId: String
    /// A JSON array of RTC stats reports for the subscriber’s stream.
    /// - Note: https://tokbox.com/developer/sdks/ios/reference/Protocols/OTSubscriberKitRtcStatsReportDelegate.html#//api/name/subscriber:rtcStatsReport:
    public var jsonArrayOfReports: String
    
    /// Default init
    public init() {
        connectionId = ""
        jsonArrayOfReports = ""
    }
    /// Initialize with connection and jsonArrayOfReports
    public init(connectionId: String, jsonArrayOfReports: String) {
        self.connectionId = connectionId
        self.jsonArrayOfReports = jsonArrayOfReports
    }
}

/// Statistics about incoming network traffic during a video visit call
public struct SubscriberNetworkStats: Encodable {
    /// The number of packets successfully received
    public var packetsReceived: UInt64
    /// The number of packets that were sent but we did not receive
    public var packetsLost: UInt64
    /// The total number of bytes received during the video conference
    public var bytesReceived: UInt64
    /// The average network bandwidth (speed) that the conference is handling.
    /// This is calculated and updated in 3 second intervals throughout the video conference. After the conference ends, this value represents the network bandwidth of the final 3 second interval. This value only represents incoming bandwidth. The value is in bits per second.
    public var bandwidthBitsPerSecond: UInt64
    /// The percentage of packets lost to the total number of packets sent to us.
    public var packetLossRatio: Double
    /// Last date time the update happened in UTC:0
    public var lastUpdated: Date {
        return Date(timeIntervalSince1970: timestamp / 1000) // divide by 1,000 as returns as linux epoch which is in milliseconds
    }
    
    internal var timestamp: Double
    
    enum CodingKeys: String, CodingKey {
        case packetsReceived
        case packetsLost
        case bytesReceived
        case bandwidthBitsPerSecond
        case packetLossRatio
        case lastUpdated
        case timestamp
    }
    
    /// Default init
    public init() {
        packetsReceived = 0
        packetsLost = 0
        bytesReceived = 0
        bandwidthBitsPerSecond = 0
        packetLossRatio = 0
        timestamp = 0
    }
    
    internal mutating func updateWithVideoStats(stats: OTSubscriberKitVideoNetworkStats) {
        if timestamp == 0 {
            timestamp = stats.timestamp
            bytesReceived = stats.videoBytesReceived
        }
        if bytesReceived > stats.videoBytesReceived {
            bytesReceived = stats.videoBytesReceived
        }
        
        if stats.timestamp - timestamp >= TIMEWINDOW {
            bandwidthBitsPerSecond = (8 * (stats.videoBytesReceived - bytesReceived)) / (UInt64(stats.timestamp - timestamp) / 1000)
            
            if packetsReceived != 0 {
                let pl = Double(stats.videoPacketsLost) - Double(packetsLost)
                let pr = Double(stats.videoPacketsReceived) - Double(packetsReceived)
                let pt = pl + pr
                if pt > 0 {
                    packetLossRatio = pl / pt
                }
            }
            packetsLost = stats.videoPacketsLost
            packetsReceived = stats.videoPacketsReceived
            timestamp = stats.timestamp
            bytesReceived = stats.videoBytesReceived
        }
    }
    
    internal mutating func updateWithAudioStats(stats: OTSubscriberKitAudioNetworkStats) {
        if timestamp == 0 {
            timestamp = stats.timestamp
            bytesReceived = stats.audioBytesReceived
        }
        if bytesReceived > stats.audioBytesReceived {
            bytesReceived = stats.audioBytesReceived
        }
        if stats.timestamp - timestamp >= TIMEWINDOW {
            bandwidthBitsPerSecond = (8 * (stats.audioBytesReceived - bytesReceived)) / (UInt64(stats.timestamp - timestamp) / 1000)
            
            if packetsReceived != 0 {
                let pl = Double(stats.audioPacketsLost) - Double(packetsLost)
                let pr = Double(stats.audioPacketsReceived) - Double(packetsReceived)
                let pt = pl + pr
                if pt > 0 {
                    packetLossRatio = pl / pt
                }
            }
            packetsLost = stats.audioPacketsLost
            packetsReceived = stats.audioPacketsReceived
            timestamp = stats.timestamp
            bytesReceived = stats.audioBytesReceived
        }
    }
    
    /// Custom encoder for sending network stats
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(packetsReceived, forKey: .packetsReceived)
        try container.encode(packetsLost, forKey: .packetsLost)
        try container.encode(bytesReceived, forKey: .bytesReceived)
        try container.encode(bandwidthBitsPerSecond, forKey: .bandwidthBitsPerSecond)
        try container.encode(packetLossRatio, forKey: .packetLossRatio)

        try container.encode(DateFormatter.iso8601FullDetailed.string(from: lastUpdated), forKey: .lastUpdated)
    }
}

/// Contains information about outgoing network traffic to a single conference participant during a virtual visit.
public struct PublisherNetworkStats: Encodable {
    /// The OpenTok (Vonage) id of the subscriber during a video conference.
    public var subscriberId: String
    /// The OpenTok (Vonage) id of the connection during a video conference.
    public var connectionId: String
    /// The number of packets that were successfully sent, and received by the subscriber.
    public var packetsSent: Int64
    /// The number of packets that were sent, but were not received by the subscriber.
    public var packetsLost: Int64
    /// The total number of bytes sent during the video conference.
    public var bytesSent: Int64
    /// The average network bandwidth (speed) that the conference is handling.
    /// This is calculated and updated in 3 second intervals throughout the video conference. After the conference ends, this value represents the network bandwidth of the final 3 second interval. This value only represents bandwidth in relation to this specific participant. The value is in bits per second.
    public var bandwidthBitsPerSecond: Int64
    /// The percentage of packets lost to the total number of packets sent to the participant.
    public var packetLossRatio: Double
    /// Last date time stats were updated. In UTC:0
    public var lastUpdated: Date {
        return Date(timeIntervalSince1970: timestamp / 1000) // divide by 1,000 as returns as linux epoch which is in milliseconds
    }
    /// Start date time of the stats collection. In UTC:0
    public var startDateTime: Date {
        return Date(timeIntervalSince1970: startTime / 1000) // divide by 1,000 as returns as linux epoch which is in milliseconds
    }
    
    internal var timestamp: Double
    internal var startTime: Double
    
    enum CodingKeys: String, CodingKey {
        case subscriberId
        case connectionid
        case packetsSent
        case packetsLost
        case bytesSent
        case bandwidthBitsPerSecond
        case packetLossRatio
        case lastUpdated
        case startDateTime
    }
    
    /// Default init
    public init() {
        connectionId = ""
        subscriberId = ""
        packetsSent = 0
        packetsLost = 0
        bytesSent = 0
        bandwidthBitsPerSecond = 0
        packetLossRatio = 0
        timestamp = 0
        startTime = 0
    }
    
    internal mutating func updateWithVideoStats(stats: OTPublisherKitVideoNetworkStats) {
        if timestamp == 0 {
            timestamp = stats.timestamp
            bytesSent = stats.videoBytesSent
            startTime = stats.startTime
        }
        
        if stats.timestamp - timestamp >= TIMEWINDOW {
            bandwidthBitsPerSecond = (8 * (stats.videoBytesSent - bytesSent)) / (Int64(stats.timestamp - timestamp) / 1000)
            
            if packetsSent != 0 {
                let pl = stats.videoPacketsLost - packetsLost
                let pr = stats.videoPacketsSent - packetsSent
                let pt = pl + pr
                if pt > 0 {
                    packetLossRatio = Double(pl) / Double(pt)
                }
            }
            packetsLost = stats.videoPacketsLost
            packetsSent = stats.videoPacketsSent
            timestamp = stats.timestamp
            bytesSent = stats.videoBytesSent
        }
    }
    
    internal mutating func updateWithAudioStats(stats: OTPublisherKitAudioNetworkStats) {
        if timestamp == 0 {
            timestamp = stats.timestamp
            bytesSent = stats.audioBytesSent
            startTime = stats.startTime
        }
        
        if stats.timestamp - timestamp >= TIMEWINDOW {
            bandwidthBitsPerSecond = (8 * (stats.audioBytesSent - bytesSent)) / (Int64(stats.timestamp - timestamp) / 1000)
            
            if packetsSent != 0 {
                let pl = stats.audioPacketsLost - packetsLost
                let pr = stats.audioPacketsSent - packetsSent
                let pt = pl + pr
                if pt > 0 {
                    packetLossRatio = Double(pl) / Double(pt)
                }
            }
            packetsLost = stats.audioPacketsLost
            packetsSent = stats.audioPacketsSent
            timestamp = stats.timestamp
            bytesSent = stats.audioBytesSent
        }
    }
        
    /// Custom encoder for sending network stats
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(subscriberId, forKey: .subscriberId)
        try container.encode(connectionId, forKey: .connectionid)
        
        try container.encode(packetsSent, forKey: .packetsSent)
        try container.encode(packetsLost, forKey: .packetsLost)
        try container.encode(bytesSent, forKey: .bytesSent)
        try container.encode(bandwidthBitsPerSecond, forKey: .bandwidthBitsPerSecond)
        try container.encode(packetLossRatio, forKey: .packetLossRatio)

        try container.encode(DateFormatter.iso8601FullDetailed.string(from: lastUpdated), forKey: .lastUpdated)
        try container.encode(DateFormatter.iso8601FullDetailed.string(from: startDateTime), forKey: .startDateTime)
    }
}
