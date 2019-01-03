//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class UserActionsDetectorsTests: XCTestCase {
    
    var detector: Detectors.UserActions!
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.UserActions()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    func testInitialState() {
        let result = detector.render(hasTime: false,
                                     action: .nothing)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPauseAndPlay() {
        var result = detector.render(hasTime: true,
                                     action: .nothing)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: true,
                                 action: .pause)
        XCTAssertEqual(result, .didPause)
        result = detector.render(hasTime: true,
                                 action: .play)
        XCTAssertEqual(result, .didPlay)
        result = detector.render(hasTime: true,
                                 action: .nothing)
        XCTAssertEqual(result, .nothing)
    }
    
    func testTwoActionsInARow() {
        var result = detector.render(hasTime: true,
                                     action: .play)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: true,
                                 action: .play)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: true,
                                 action: .pause)
        XCTAssertEqual(result, .didPause)
        result = detector.render(hasTime: true,
                                 action: .pause)
        XCTAssertEqual(result, .nothing)
    }
    func testPauseAndPlayNoTime() {
        var result = detector.render(hasTime: true,
                                     action: .nothing)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: true,
                                 action: .play)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: false,
                                 action: .pause)
        XCTAssertEqual(result, .nothing)
        result = detector.render(hasTime: true,
                                 action: .play)
        XCTAssertEqual(result, .nothing)
    }
}
