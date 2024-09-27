import Foundation

public struct VirtualVisitTypeName: RawRepresentable, Codable, Equatable {
    public typealias RawValue = String
    public var rawValue: String

    /// Representing a regular virtual visit type
    public static let virtual = VirtualVisitTypeName(rawValue: "virtual")
    /// Representing a virtual visit type over the phone
    public static let phone = VirtualVisitTypeName(rawValue: "phone")

    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}
