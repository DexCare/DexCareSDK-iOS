import Foundation

/// WaitTime structure returns when loading `VirtualService.getEstimatedWaitTime`
public struct WaitTime: Decodable, Equatable {
    /// Date at UTC of when the estimated time was generated. Estimates are cached and updated at various intervals.
    public var generatedAt: Date
    /// Estimated wait time in seconds of the practice region, or when in the virtual visit waiting room.
    public var estimatedWaitTimeSeconds: Int
    /// Message that is shown in the waiting room.
    public var estimatedWaitTimeMessage: String?
    /// Information that allows localization of estimated wait time
    public var waitTimeLocalizationInfo: WaitTimeLocalizationInfo?

    enum CodingKeys: String, CodingKey {
        case generatedAt = "estimateGeneratedAt"
        case estimatedWaitTimeSeconds
        case estimatedWaitTimeMessage
        case waitTimeLocalizationInfo
    }

    /// An internal decoder to handle dates.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let waitTimeSecondsString = try values.decode(Double.self, forKey: CodingKeys.estimatedWaitTimeSeconds)

        self.estimatedWaitTimeSeconds = Int(waitTimeSecondsString)
        self.estimatedWaitTimeMessage = try? values.decodeIfPresent(String.self, forKey: CodingKeys.estimatedWaitTimeMessage)

        let generatedAtString = try values.decode(String.self, forKey: CodingKeys.generatedAt)
        if let generatedAt = DateFormatter.iso8601Full.date(from: generatedAtString) {
            self.generatedAt = generatedAt
        } else {
            throw "Invalid generatedAt format"
        }

        self.waitTimeLocalizationInfo = try? values.decode(WaitTimeLocalizationInfo.self, forKey: CodingKeys.waitTimeLocalizationInfo)
    }

    // Initializer used only for stubbing tests
    init(
        generatedAt: Date,
        estimatedWaitTimeSeconds: Int,
        estimatedWaitTimeMessage: String?,
        waitTimeLocalizationInfo: WaitTimeLocalizationInfo?
    ) {
        self.generatedAt = generatedAt
        self.estimatedWaitTimeSeconds = estimatedWaitTimeSeconds
        self.estimatedWaitTimeMessage = estimatedWaitTimeMessage
        self.waitTimeLocalizationInfo = waitTimeLocalizationInfo
    }
}
