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
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testAdPlayingProcess() {
        let id = UUID()
        var result = sut.process(sessionID: id,
                                 adPlaying: false,
                                 adSkipped: false,
                                 adFailed: false,
                                 contentPlaying: false)
        XCTAssertFalse(result)
        result = sut.process(sessionID: id,
                             adPlaying: true,
                             adSkipped: false,
                             adFailed: false,
                             contentPlaying: false)
        XCTAssertTrue(result)
        
        result = sut.process(sessionID: id,
                             adPlaying: true,
                             adSkipped: false,
                             adFailed: false,
                             contentPlaying: false)
        XCTAssertFalse(result)
    }
    
    func testAdSkipProcess() {
        let id = UUID()
        var result = sut.process(sessionID: id,
                                 adPlaying: false,
                                 adSkipped: true,
                                 adFailed: false,
                                 contentPlaying: false)
        XCTAssertFalse(result)
        
        result = sut.process(sessionID: id,
                             adPlaying: false,
                             adSkipped: true,
                             adFailed: false,
                             contentPlaying: true)
        XCTAssertTrue(result)
        
        result = sut.process(sessionID: id,
                             adPlaying: false,
                             adSkipped: true,
                             adFailed: false,
                             contentPlaying: true)
        XCTAssertFalse(result)
    }
    
    func testAdFailProcess() {
        let id = UUID()
        var result = sut.process(sessionID: id,
                                 adPlaying: false,
                                 adSkipped: false,
                                 adFailed: true,
                                 contentPlaying: false)
        XCTAssertFalse(result)
        
        result = sut.process(sessionID: id,
                             adPlaying: false,
                             adSkipped: false,
                             adFailed: true,
                             contentPlaying: true)
        XCTAssertTrue(result)
        
        result = sut.process(sessionID: id,
                             adPlaying: false,
                             adSkipped: false,
                             adFailed: true,
                             contentPlaying: true)
        XCTAssertFalse(result)
    }
    
    func testSessionChnageProcess() {
        let id = UUID()
        _ = sut.process(sessionID: id,
                        adPlaying: true,
                        adSkipped: false,
                        adFailed: false,
                        contentPlaying: false)
        XCTAssertTrue(sut.playbackInitiated)
        
        _ = sut.process(sessionID: UUID(),
                        adPlaying: false,
                        adSkipped: false,
                        adFailed: false,
                        contentPlaying: false)
        XCTAssertFalse(sut.playbackInitiated)
    }
}
