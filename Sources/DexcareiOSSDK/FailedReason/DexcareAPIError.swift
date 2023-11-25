import Foundation

/// Type to hold information on certain DexCare network calls
public struct DexcareAPIError {
    /// Specific message on what the error is
    let message: String
    /// internal error code for use in debugging
    let errorCode: Int
}
