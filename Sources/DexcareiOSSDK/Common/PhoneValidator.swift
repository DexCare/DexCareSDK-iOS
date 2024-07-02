// Copyright © 2020 DexCare. All rights reserved.

import Foundation

/// A class to that the SDK uses to check for valid phone numbers
public class PhoneValidator {
    @available(*, unavailable, renamed: "phoneValidationRegex")
    /// The regex value that is used to check for phone validity
    public static let PHONE_VALIDATION_REGEX = ""
    
    /// The regex value that is used to check for phone validity
    public static let phoneValidationRegex = "^1? ?\\(?[2-9][0-8][0-9]\\)?[ -]?[2-9][0-9]{2}[ -]?[0-9]{4}$"
    
    /**
    A class function that tests whether or not a phone number is valid.
    - Note:
     This is a simple regex test using the phoneValidationRegex value
     A convenience String method .isValidPhoneNumber() is also available    
    */
    public static func isValid(phoneNumber: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", phoneValidationRegex)
        return predicate.evaluate(with: phoneNumber)
    }
    
    static func removeNonDecimalCharacters(_ formattedPhoneNumber: String) -> String {
        var digits = ""
        
        for char in formattedPhoneNumber where CharacterSet.decimalDigits.contains(char.unicodeScalars.first!) {
            digits += String(char)
        }
        return digits
    }
}

extension String {
    /// A String extension convenience helper that calls PhoneValidator.isValid(phoneNumber)
    public func isValidPhoneNumber() -> Bool {
        return PhoneValidator.isValid(phoneNumber: self)
    }
}
