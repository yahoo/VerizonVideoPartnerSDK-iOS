//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension String {
    var nonEmpty: String? {
        return count > 0 ? self : nil
    }
}
