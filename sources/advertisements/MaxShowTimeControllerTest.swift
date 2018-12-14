//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import PlayerCore
@testable import OathVideoPartnerSDK

class MaxShowTimeControllerTest: XCTestCase {
    
    class MockTimer: Cancellable {
        var didCancelCalled = false
        
        func cancel() {
            didCancelCalled = true
        }
    }
    
    func testMaxShowTimeController() {

        var timer: MockTimer!
        let sut = MaxShowTimeController(timerCreator: { duration in
            XCTAssertEqual(duration, 10)
            timer = MockTimer()
            return timer
        }, maxAdDuration: -1) { _ in }
        
        sut.process(timerSessionState: .running,
                    allowedDuration: 10)
        XCTAssertNotNil(sut.timer)
        
        sut.process(timerSessionState: .running,
                    allowedDuration: -1)
        
        sut.process(timerSessionState: .paused,
                    allowedDuration: -1)
        XCTAssertNil(sut.timer)
        XCTAssertTrue(timer.didCancelCalled)
        
        sut.process(timerSessionState: .running,
                    allowedDuration: 10)
        XCTAssertNotNil(sut.timer)
        
        XCTAssertFalse(timer.didCancelCalled)
        sut.process(timerSessionState: .stopped,
                    allowedDuration: -1)
        XCTAssertNil(sut.timer)
        XCTAssertTrue(timer.didCancelCalled)
    }
    
}
