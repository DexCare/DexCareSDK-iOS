import Foundation

/// A generic Question + Answer object that can be passed up inside the `RetailVisitInformation` or `ProviderVisitInformation` object
public struct PatientQuestion: Codable, Equatable {
    /// A String representing a question
    public var question: String
    /// A String representing an answer
    public var answer: String
}
