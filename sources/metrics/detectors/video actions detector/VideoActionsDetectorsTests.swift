//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class VideoActionsDetectorsTests: XCTestCase {
    
    var detector: Detectors.VideoActions!
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.VideoActions()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    func testInitialState() {
        let result = detector.render(actionInitiated: .unknown,
                                     isAutoplay: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPlayWithoutAutoplay() {
        let result = detector.render(actionInitiated: .play,
                                     isAutoplay: false)
        XCTAssertEqual(result, .didPlay)
    }
    
    func testPauseWithoutAutoplay() {
        let result = detector.render(actionInitiated: .pause,
                                     isAutoplay: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPauseAfterPlayWithoutAutoplay() {
        var result = detector.render(actionInitiated: .play,
                                     isAutoplay: false)
        XCTAssertEqual(result, .didPlay)
        result = detector.render(actionInitiated: .pause,
                                 isAutoplay: false)
        XCTAssertEqual(result, .didPause)
    }
    
    func testUnknownAfterPauseWithoutAutoplay() {
        var result = detector.render(actionInitiated: .pause,
                                     isAutoplay: false)
        XCTAssertEqual(result, .nothing)
        result = detector.render(actionInitiated: .unknown,
                                 isAutoplay: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPlayWithAutoplay() {
        let result = detector.render(actionInitiated: .play,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPauseAfterPlayWithAutoplay() {
        var result = detector.render(actionInitiated: .play,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
        result = detector.render(actionInitiated: .pause,
                                 isAutoplay: true)
        XCTAssertEqual(result, .didPause)
    }
    
    func testPlayAfterPlayWithAutoplay() {
        var result = detector.render(actionInitiated: .play,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
        result = detector.render(actionInitiated: .play,
                                 isAutoplay: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testPauseAfterPauseWithAutoplay() {
        var result = detector.render(actionInitiated: .pause,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
        result = detector.render(actionInitiated: .pause,
                                 isAutoplay: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testUnknownAfterPauseWithAutoplay() {
        var result = detector.render(actionInitiated: .pause,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
        
        result = detector.render(actionInitiated: .unknown,
                                 isAutoplay: true)
        XCTAssertEqual(result, .nothing)
    }
    
    func testUnknownAfterPlayWithAutoplay() {
        var result = detector.render(actionInitiated: .play,
                                     isAutoplay: true)
        XCTAssertEqual(result, .nothing)
        result = detector.render(actionInitiated: .unknown,
                                 isAutoplay: true)
        XCTAssertEqual(result, .nothing)
    }
}
