//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble
import struct PlayerCore.Progress
@testable import VerizonVideoPartnerSDK

class VideoTimeDetectorTests: XCTestCase {
    
    var detector = Detectors.VideoTime()
    var id = UUID()
    var isCompleted = false
    var isStreamPlaying = true
    var progress: Progress = 0
    var playTime: TimeInterval = 0
    var index = 0
    
    var payload: Detectors.VideoTime.Payload {
        return Detectors.VideoTime.Payload(
            index: index,
            progress: progress,
            session: id, playTime: playTime)
    }
    
    var detectedPayload: Detectors.VideoTime.Payload? {
        return detector.process(sessionID: id,
                           isCompleted: isCompleted,
                           isStreamPlaying: isStreamPlaying,
                           payload: payload)
    }
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.VideoTime()
        id = UUID()
        isCompleted = false
        isStreamPlaying = false
        progress = 0
        playTime = 0
        index = 0
    }
    
    func testNoReports() {
        isStreamPlaying = true
        XCTAssertNil(detectedPayload)
        
        isStreamPlaying = false
        XCTAssertNil(detectedPayload)
        
        
        isStreamPlaying = false
        playTime = 10
        progress = 1
        XCTAssertNil(detectedPayload)
    }
    
    func testSessionEnd() {
        
        playTime = 10
        isStreamPlaying = true
        progress = 1.0
        
        XCTAssertNil(detectedPayload)
        
        
        isStreamPlaying = false
        isCompleted = true
        
        guard let payload = detectedPayload else { return XCTFail("Session end did not detected") }
        
        XCTAssertEqual(payload.playTime, 10)
        XCTAssertEqual(payload.index, 0)
        XCTAssertEqual(payload.progress, 1)
    }
    
    func testVideoSwitch() {
        
        isStreamPlaying = true
        XCTAssertNil(detectedPayload)
        
        playTime = 10
        progress = 0.6
        XCTAssertNil(detectedPayload)
        
        let oldSessionID = id
        id = UUID()
        index = 1
        
        guard let payload = detectedPayload else { return XCTFail("Session end did not detected") }
        
        XCTAssertEqual(payload.playTime, 10)
        XCTAssertEqual(payload.index, 0)
        XCTAssertEqual(payload.progress, 0.6)
        XCTAssertEqual(payload.session, oldSessionID)
    }
    
    func testVideoPlaybackHasEndedPlayerWasClosed() {
        
        isStreamPlaying = true
        XCTAssertNil(detectedPayload)
        
        isStreamPlaying = false
        XCTAssertNil(detectedPayload)
        
        isCompleted = true
        XCTAssertNotNil(detectedPayload)
    }
    
    func testVideoPlaybackHasEndedVideoWasSwitched() {
        isStreamPlaying = true
        XCTAssertNil(detectedPayload)
        
        isStreamPlaying = false
        XCTAssertNil(detectedPayload)
        
        id = UUID()
        index = 1
        XCTAssertNotNil(detectedPayload)
    }
}
