//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble
@testable import VerizonVideoPartnerSDK

class ContextIntentDetectorTests: XCTestCase {
    func testProcessing() {
        let sut = ExecuteOnce()
        
        sut.process(if: false, onDetect: { fail() })
        sut.process(if: false, onDetect: { fail() })
        sut.process(if: true, onDetect: { expect(sut.isExecuted) == true })
        sut.process(if: true, onDetect: { fail() })
        sut.process(if: false, onDetect: { fail() })
    }
}
