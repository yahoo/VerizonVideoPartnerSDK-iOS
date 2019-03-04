//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import VerizonVideoPartnerSDK

class MockTimer: VerizonVideoPartnerSDK.Cancellable {
    var didCancelCalled = false
    
    func cancel() {
        didCancelCalled = true
    }
    
}
