// Copyright © 2020 DexCare. All rights reserved.

/// A generic representation of a Gender
@frozen
public enum Gender: String, Equatable {
    case male = "male"
    case female = "female"
    /// Used as an EPIC option in some EHR's
    case other = "other"
    /// Used as an EPIC option in some EHR's
    case unknown = "unknown" // for Froedert
}

public extension Gender {
    
    /// Value sent in network requests
    var demographicStringValue: String {
        return self.rawValue
    }
    
    static func fromDemographicsString(_ text: String?) -> Gender? {
        guard let text = text else { return nil}
        switch text.lowercased() {
        case Gender.male.demographicStringValue.lowercased(): return Gender.male
        case Gender.female.demographicStringValue.lowercased(): return Gender.female
        case Gender.other.demographicStringValue.lowercased(): return Gender.other
        case Gender.unknown.demographicStringValue.lowercased(): return Gender.unknown
        default: return nil
        }
    }
}

extension Gender: Codable {
    public init(from decoder: Decoder) throws {
        let gender = try decoder.singleValueContainer().decode(String.self)
        self = Gender.fromDemographicsString(gender) ?? .male
    }
}
