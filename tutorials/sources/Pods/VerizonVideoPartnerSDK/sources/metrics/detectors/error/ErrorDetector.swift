//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class ErrorDetector {
        
        private var error: NSError?
        
        func process(error: Error?, onDetect: Action<NSError>) {
            guard let error = error as NSError? else { return }
            guard self.error != error else { return }
            
            self.error = error
            
            onDetect(error)
        }
    }
}
