//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK

class MuteDetectorsTests: XCTestCase {
    
    var detector: Detectors.Mute!
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.Mute()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    func testInitialState() {
        let result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testMuteAndUnmute() {
        var result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
        
        result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .unmute)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
    }
    
    func testTwoActionsInARow() {
        var result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .unmute)
        
        result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testAdFinished() {
        var result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
        
        result = detector.process(isMuted: false, isNotFinished: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testExpectUnmuteOnlyAfterMute() {
        var result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
        
        result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .unmute)
        
        result = detector.process(isMuted: false, isNotFinished: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testExpectMuteBeingFiredAfterMute() {
        var result = detector.process(isMuted: false, isNotFinished: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
        
        result = detector.process(isMuted: true, isNotFinished: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true)
        XCTAssertEqual(result, .mute)
    }
    func testOpenMeasurementProcessMethod() {
        var result = detector.process(isMuted: false, isNotFinished: true, isOMActive: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true, isOMActive: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.process(isMuted: true, isNotFinished: true, isOMActive: true)
        XCTAssertEqual(result, .mute)
    }
}
