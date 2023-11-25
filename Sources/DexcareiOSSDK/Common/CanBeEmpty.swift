// Copyright © 2018 Providence. All rights reserved.

import Foundation

protocol CanBeEmpty {
    var isEmpty: Bool { get }
}

extension CanBeEmpty {
    var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension String: CanBeEmpty { }
extension Array: CanBeEmpty { }

extension Optional: CanBeEmpty {
    
    var isEmpty: Bool {
        switch self {
        case .none: return true
        case .some(let wrapped):
            if let wrapped = wrapped as? CanBeEmpty {
                return wrapped.isEmpty
            }
            return false
        }
    }
}

extension String {
    static var empty = ""
}
