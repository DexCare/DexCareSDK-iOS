import Foundation

public struct VirtualVisitModality: RawRepresentable, Codable, Equatable {
    public typealias RawValue = String
    public var rawValue: String

    enum CodingKeys: String, CodingKey {
        case rawValue = "name"
    }

    /// Representing a regular virtual visit type
    public static let virtual = VirtualVisitModality(rawValue: "virtual")
    /// Representing a pediatric virtual visit
    public static let phone = VirtualVisitModality(rawValue: "phone")

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.rawValue = try values.decode(String.self, forKey: .rawValue)
    }

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}
