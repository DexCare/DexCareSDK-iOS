// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// A class to that the SDK uses to check for valid zip codes numbers
public class ZipCodeValidator {
        
    @available(*, unavailable, renamed: "zipCodeValidationRegex")
    /// The regex value that is used to check for zip validity
    public static let ZIP_CODE_VALIDATION_REGEX = ""
    
    /// The regex value that is used to check for zip validity
    public static let zipCodeValidationRegex = "^\\d{5}(-\\d{4})?$"
    
    /// A class function that tests whether or not a zip code is valid.
    /// Will check
    /// 1. if 5 digits or 9 digits (with a hyphen)
    /// 2. The first 5 digits must be between "00501" and "99999", inclusive
    /// 3. For 5+4 digit zip codes, there **must** be a hyphen after the first 5 digits. e.g. 90210-1234
    /// - Note: A convenience String method .isValidZipCode() is also available
    public static func isValid(zipCode: String) -> Bool {
        guard let fiveDigits = Int(zipCode.prefix(5)) else {
            return false
        }
        
        let predicate = NSPredicate(format: "SELF MATCHES %@", zipCodeValidationRegex)
        
        return predicate.evaluate(with: zipCode) && fiveDigits >= 501
    }
}

extension String {
    /// A String extension convenience helper that calls ZipCodeValidator.isValid(zipCode)
    public func isValidZipCode() -> Bool {
        return ZipCodeValidator.isValid(zipCode: self)
    }
}
