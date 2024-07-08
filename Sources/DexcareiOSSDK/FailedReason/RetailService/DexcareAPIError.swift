import Foundation

/// Type to hold information on certain DexCare network calls
public struct DexcareAPIError {
    /// Specific message on what the error is
    public let message: String
    /// internal error code for use in debugging
    public let errorCode: Int
}
