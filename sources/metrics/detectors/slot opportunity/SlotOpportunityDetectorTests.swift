//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class SlotOpportunityDetectorTests: XCTestCase {
    var sut: Detectors.SlotOpportunity!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.SlotOpportunity()
    }
    
    func testPlayingProcess() {
        let id = UUID()
        var result = sut.process(sessionID: id, playbackStarted: false)
        XCTAssertFalse(result)
        
        result = sut.process(sessionID: id, playbackStarted: true)
        XCTAssertTrue(result)
        
        result = sut.process(sessionID: id, playbackStarted: true)
        XCTAssertFalse(result)
    }
    
    func testSessionChanageProcess() {
        let firstAd = UUID()
        let secondAd = UUID()
        
        var result = sut.process(sessionID: firstAd, playbackStarted: true)
        XCTAssertTrue(result)
        
        result = sut.process(sessionID: secondAd, playbackStarted: false)
        XCTAssertFalse(result)
        
        result = sut.process(sessionID: secondAd, playbackStarted: true)
        XCTAssertTrue(result)
    }
}
