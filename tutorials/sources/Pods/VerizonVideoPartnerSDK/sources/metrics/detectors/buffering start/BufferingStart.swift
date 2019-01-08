//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class BufferingStart {
        
        var isBufferingStarted = false
        func process(adIsBuffering: Bool, contentIsBuffering: Bool, onDetect: ActionWithVoid) {
            let isBuffering = adIsBuffering || contentIsBuffering
            
            guard self.isBufferingStarted != isBuffering else { return }
            self.isBufferingStarted = isBuffering
            guard self.isBufferingStarted else { return }
            
            onDetect()
        }
        
    }
}
