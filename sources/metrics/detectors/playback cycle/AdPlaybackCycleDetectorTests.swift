//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class PlaybackCycleDetectorTests: XCTestCase {
    var sut: Detectors.AdPlaybackCycle!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.AdPlaybackCycle()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testSuccessfulAd() {
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .start)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isSuccessfullyCompleted: true,
                                   isForceFinished: false),
                       .complete)
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .nothing)
    }
    func testBrokenAd() {
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .start)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isSuccessfullyCompleted: false,
                                   isForceFinished: true),
                       .nothing)
    }
}
