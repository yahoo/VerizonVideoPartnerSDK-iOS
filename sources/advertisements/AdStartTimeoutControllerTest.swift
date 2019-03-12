//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class AdStartTimeoutControllerTest: XCTestCase {
    
    var sut: AdStartTimeoutController!
    let recorder = Recorder()
    var onFire: () -> () = {}
    
    func testAdStartTimeoutControllerForVPAID() {
        let actionComparator = ActionComparator<VPAIDAdStartTimeout> { _,_ in return true }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        let timer = MockTimer()
        
        sut = AdStartTimeoutController(dispatcher: dispatch) { [weak self] onFire in
            self?.onFire = onFire
            return timer
        }
        
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: false,
                        isVPAIDCreative: true)
        }
        recorder.verify {}
        
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: false,
                        isVPAIDCreative: true)
            onFire()
        }
        recorder.verify {
            dispatch(VPAIDAdStartTimeout())
        }
    }
    func testAdStartTimeoutControllerForMP4() {
        let actionComparator = ActionComparator<MP4AdStartTimeout> { _,_ in return true }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        let timer = MockTimer()
        
        sut = AdStartTimeoutController(dispatcher: dispatch) { [weak self] onFire in
            self?.onFire = onFire
            return timer
        }
        
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: false,
                        isVPAIDCreative: false)
        }
        recorder.verify {}
        
        recorder.record {
            onFire()
        }
        recorder.verify {
            dispatch(MP4AdStartTimeout())
        }
    }
    func testAdStartTimeoutControllerCancelled() {
        let actionComparator = ActionComparator<MP4AdStartTimeout> { _,_ in return true }
        let dispatch = recorder.hook("dispatch", cmp: actionComparator.compare)
        let timer = MockTimer()
        
        sut = AdStartTimeoutController(dispatcher: dispatch) { [weak self] onFire in
            self?.onFire = onFire
            return timer
        }
        
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: false,
                        isVPAIDCreative: false)
        }
        recorder.verify {}
        XCTAssertFalse(timer.didCancelCalled)
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: true,
                        isVPAIDCreative: false)
        }
        recorder.verify {}
        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertNotNil(sut.timer)
        
        timer.didCancelCalled = false
        
        recorder.record {
            sut.process(currentAdState: .play,
                        isStreamPlaying: false,
                        isVPAIDCreative: false)
        }
        XCTAssertFalse(timer.didCancelCalled)
        recorder.verify {}
        recorder.record {
            sut.process(currentAdState: .empty,
                        isStreamPlaying: false,
                        isVPAIDCreative: false)
        }
        recorder.verify {}
        XCTAssertTrue(timer.didCancelCalled)
        XCTAssertNil(sut.timer)
    }
}
