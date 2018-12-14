//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class AdClick {
        var processed = false
        
        func process(clicked: Bool) -> Bool {
            switch (processed, clicked) {
            case (true, false),
                 (false, true):
                processed = clicked
                return clicked
            default:
                return false
            }
        }
    }
}
