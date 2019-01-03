//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class PlaybackCycleDetectorTests: XCTestCase {
    var sut: Detectors.PlaybackCycle!
    
    override func setUp() {
        super.setUp()
        
        sut = Detectors.PlaybackCycle()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    func testProcess() {
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isFinished: false),
                       .beginPlaying)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isFinished: false),
                       .nothing)
        XCTAssertEqual(sut.process(streamPlaying: false,
                                   isFinished: true),
                       .endPlaying)
        XCTAssertEqual(sut.process(streamPlaying: true,
                                   isFinished: true),
                       .nothing)
    }
}
