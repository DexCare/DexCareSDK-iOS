// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// A class to that the SDK uses to check for valid emails
public class EmailValidator {
    @available(*, unavailable, renamed: "emailValidationRegex")
    /// The hardcoded regex bundled with the SDK. If the SDK is unable to retrieve the regex from the server config, this regex will be used for validation instead.
    public static let EMAIL_VALIDATION_REGEX = ""

    @available(*, unavailable, renamed: "emailValidationRegex")
    /**
     * An email validation string that is retrieved from the DexCare backend after initializing the SDK.
     * The backend services all use this shared regex from config for email validation.
     * Failing to validate with this regex string will result in 400 errors from the services.
     *
     * After this regex string has been successfully retrieved from the server config,
     * it is used in place of the `EMAIL_VALIDATION_REGEX` bundled with the SDK.
     */
    public internal(set) static var EMAIL_REGEX_FROM_CONFIG = ""

    /**
     * An email validation string that is retrieved from the DexCare backend after initializing the SDK.
     * The backend services all use this shared regex from config for email validation.
     * Failing to validate with this regex string will result in 400 errors from the services.
     *
     * Until the configuration is successfully retrieved it uses a hardcode value of `[A-Z0-9a-z._%+-]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,64}`
     */
    public internal(set) static var emailValidationRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.]+\\.[A-Za-z]{2,64}"

    /**
      A class function that tests whether or not a email is valid.
      Emails with dashes in the domain are not accepted.
      - Note:
      This is a simple regex test using the emailValidationRegex value.
      A convenience String method .isValidEmail() is also available
     */
    public static func isValid(email: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailValidationRegex)
        return predicate.evaluate(with: email)
    }
}

public extension String {
    /// A String extension convenience helper that calls EmailValidator.isValid(email)
    func isValidEmail() -> Bool {
        return EmailValidator.isValid(email: self)
    }
}
