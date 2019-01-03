//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class IntentDetectorTests: XCTestCase {
    
    func testNoDetections() {
        let sut = Detectors.Intent()
        sut.process(isVideoAvailable: true,
                    isPlaybackInitiated: false,
                    sessionId: UUID()) { XCTFail() }
        
        sut.process(isVideoAvailable: false,
                    isPlaybackInitiated: true,
                    sessionId: UUID()) { XCTFail() }
    }
    
    func testMultipleDetections() {
        let sut = Detectors.Intent()
        var detectCount = 0
        
        let id = UUID()
        
        sut.process(isVideoAvailable: true,
                    isPlaybackInitiated: true,
                    sessionId: id) { detectCount += 1 }
        
        sut.process(isVideoAvailable: true,
                    isPlaybackInitiated: true,
                    sessionId: id) { XCTFail() }
        
        XCTAssertEqual(detectCount, 1)
        
        sut.process(isVideoAvailable: true,
                    isPlaybackInitiated: true,
                    sessionId: UUID()) { detectCount += 1 }

        XCTAssertEqual(detectCount, 2)
    }
}
