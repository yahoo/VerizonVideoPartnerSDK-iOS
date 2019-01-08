//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

final class ExecuteOnce {
    var isExecuted = false
    
    func process(if condition: Bool, onDetect: Action<Void>) {
        guard !isExecuted else { return }
        guard condition else { return }
        
        isExecuted = true
        onDetect(())
    }
}
