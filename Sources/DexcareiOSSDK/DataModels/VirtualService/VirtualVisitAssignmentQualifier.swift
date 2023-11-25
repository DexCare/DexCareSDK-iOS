import Foundation

public struct VirtualVisitAssignmentQualifier: RawRepresentable, Codable, Equatable {
    public typealias RawValue = String
    public var rawValue: String
    
    enum CodingKeys: String, CodingKey {
        case rawValue = "name"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.rawValue = try values.decode(String.self, forKey: .rawValue)
    }
    
    public init(rawValue: Self.RawValue) {
        self.rawValue = rawValue
    }
}
