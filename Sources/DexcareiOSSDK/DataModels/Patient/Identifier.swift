// Copyright © 2020 DexCare. All rights reserved.

/// A struct representing an EHRSystem + identifier
public struct Identifier: Equatable, Codable {
    /// The EHRSystem name of the id
    let system: String
    /// The identifier unique to the EHRSystem
    let value: String?
    /// A string representing the type of identifier for each EHRSystem.
    let type: String?
}

extension Identifier {
    /// helper Init to nil out the value and type properties
    init(systemName: String) {
        self.system = systemName
        self.value = nil
        self.type = nil
    }
}
