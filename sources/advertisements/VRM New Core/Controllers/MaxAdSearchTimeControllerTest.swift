//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class MaxAdSearchTimeControllerTest: XCTestCase {

    let recorder = Recorder()
    var sut: MaxAdSearchTimeController!
    var timer: MockTimer!
    var timerInitCallCount: Int!
    
    override func setUp() {
        super.setUp()
        timer = MockTimer()
        timerInitCallCount = 0
        let timerFactory: (UUID) -> Cancellable = { _ in
            self.timerInitCallCount += 1
            return self.timer
        }
        
        sut = MaxAdSearchTimeController(timerFactory: timerFactory)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testNoStartIfRequestNil() {
        sut.process(requestID: nil, isStreamStarted: false)
        
        XCTAssertFalse(timer.didCancelCalled)
        XCTAssertEqual(timerInitCallCount, 0)
    }
    
    func testStartTimerOnNewRequest() {
        sut.process(requestID: UUID(),
                    isStreamStarted: false)
        
        sut.process(requestID: UUID(),
                    isStreamStarted: false)
        
        XCTAssertFalse(timer.didCancelCalled)
        XCTAssertEqual(timerInitCallCount, 2)
    }
    
    func testCancelTimerIfPlaybackStarted() {
        let requestID = UUID()
        sut.process(requestID: requestID,
                    isStreamStarted: false)
        
        sut.process(requestID: requestID,
                    isStreamStarted: true)
        
        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertEqual(timerInitCallCount, 1)
    }
    
    func testDoubleDispatch() {
        let requestID = UUID()
        sut.process(requestID: requestID,
                    isStreamStarted: false)
        
        sut.process(requestID: requestID,
                    isStreamStarted: false)
        
        XCTAssertFalse(timer.didCancelCalled)
        XCTAssertEqual(timerInitCallCount, 1)
        
        sut.process(requestID: requestID,
                    isStreamStarted: true)

        sut.process(requestID: requestID,
                    isStreamStarted: true)

        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertEqual(timerInitCallCount, 1)
    }
}
