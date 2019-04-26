//  Copyright © 2019 Oath Inc. All rights reserved.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension JSøN {
    var bool: Bool? {
        guard case .bool(let bool) = self else { return nil }
        return bool
    }
    
    var number: NSNumber? {
        guard case .number(let number) = self else { return nil }
        return number
    }
    
    var null: NSNull? {
        guard case .null = self else { return nil }
        return NSNull()
    }
    
    var string: String? {
        guard case .string(let string) = self else { return nil }
        return string
    }
    
    var array: [JSøN]? {
        guard case .array(let array) = self else { return nil }
        return array
    }
    
    var object: [String: JSøN]? {
        guard case .object(let object) = self else { return nil }
        return object
    }
}
