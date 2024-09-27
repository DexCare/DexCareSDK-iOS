import Foundation

/// A structure holding information on customizing the DexcareSDK
public struct CustomizationOptions: Equatable {
    /// Values for customization of the TytoCare integration
    /// This value can be set after the first initialization of the SDK, but must be set before you start a virtual visit.
    public var tytoCareConfig: TytoCareConfig?

    /// Options for the Virtual Visit experience.
    /// This value can be set after the first initialization of the SDK, but must be set before you start a virtual visit.
    public var virtualConfig: VirtualConfig?

    /// Whether or not to validate emails
    /// If **true**, all emails passed in the SDK will be validated with a regex found at `EmailValidator.EMAIL_VALIDATION_REGEX`
    /// If set to **false**, no validation will happen, and it is up to you to validate any invalid emails.
    /// - Note: default is **true**
    public var validateEmails: Bool

    public init(tytoCareConfig: TytoCareConfig? = nil, virtualConfig: VirtualConfig? = nil, validateEmails: Bool = true) {
        self.tytoCareConfig = tytoCareConfig
        self.virtualConfig = virtualConfig
        self.validateEmails = validateEmails
    }
}

extension CustomizationOptions {
    /// helper method for validate emails
    init(validateEmails: Bool) {
        self.tytoCareConfig = nil
        self.virtualConfig = nil
        self.validateEmails = validateEmails
    }
}
