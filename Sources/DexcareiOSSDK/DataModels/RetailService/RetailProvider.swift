//  Copyright © 2024 DexCare. All rights reserved.

public struct RetailProvider: Equatable, Codable {
    /// The identifier for this Retail Provider.
    public let providerId: String
    /// The EMR ID for the provider services.
    public let emrId: String
    /// The national identifier for this Retail Provider.
    public let nationalId: String
    /// The provider's first name.
    public let firstName: String
    /// The provider's last name.
    public let lastName: String
    /// The title for provider's name.
    public let title: String?
    /// The provider's medical credential.
    public let credential: String?
}
