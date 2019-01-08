//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension Detectors {
    final class AdError {
        var detected = false
        var id: UUID?
        
        struct Result {
            let error: Error
        }
        
        func process(id: UUID?, error: Error?) -> Result? {
            guard let id = id else { return nil }
            if self.id != id {
                self.detected = false
                self.id = id
            }
            
            guard detected == false, let error = error else { return nil }
            
            self.detected = true
            
            return Result(error: error)
        }
    }
}
