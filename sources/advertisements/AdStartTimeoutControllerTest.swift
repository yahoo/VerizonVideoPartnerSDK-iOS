//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


import XCTest
@testable import OathVideoPartnerSDK

class AdStartTimeoutControllerTest: XCTestCase {
    
    class MockTimer: OathVideoPartnerSDK.Cancellable {
        var didCancelCalled = false
        
        func cancel() {
            didCancelCalled = true
        }
    }
    
    var sut: AdStartTimeoutController!
    
    func testAdStartTimeoutController() {
        var timerCreatorCall = 0
        var timer: MockTimer!
        let sut = AdStartTimeoutController {
            timerCreatorCall += 1
            timer = MockTimer()
            return timer
        }
        
        XCTAssertNil(sut.timer)
        
        sut.process(currentAdState: .play,
                    isStreamPlaying: false)
        XCTAssertNotNil(sut.timer)
        
        sut.process(currentAdState: .play,
                    isStreamPlaying: false)
        XCTAssertNotNil(sut.timer)
        XCTAssertEqual(timerCreatorCall, 1)
        
        sut.process(currentAdState: .play,
                    isStreamPlaying: true)
        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertNotNil(sut.timer)
        XCTAssertEqual(timerCreatorCall, 1)
        
        sut.process(currentAdState: .empty,
                    isStreamPlaying: false)
        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertNil(sut.timer)
    }
    
}
