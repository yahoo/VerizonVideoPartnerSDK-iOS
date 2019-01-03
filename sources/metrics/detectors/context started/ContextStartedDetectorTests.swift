//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class ContextStartedDetectorTests: XCTestCase {
    var sut: Detectors.ContextStarted!
    var detectCount = 0
    
    func increase() { detectCount += 1 }
    
    func check(_ assertion: @autoclosure () -> (), after code: () -> ()) {
        code()
        assertion()
    }
    
    override func setUp() {
        super.setUp()
        
        detectCount = 0
        sut = Detectors.ContextStarted()
    }
    
    func testInitial() {
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: false,
                                                       adIsStreamPlaying: false,
                                                       sessionId: UUID())
        check(XCTAssertEqual(detectCount, 0)) {
            sut.process(input: mockInput, onDetect: increase)
        }
        
    }
    
    func testContentPlaying() {
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                       adIsStreamPlaying: false,
                                                       sessionId: UUID())
        
        check(XCTAssertEqual(detectCount, 1)) {
            sut.process(input: mockInput, onDetect: increase)
        }
    }
    
    func testAdPlaying() {
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: false,
                                                       adIsStreamPlaying: true,
                                                       sessionId: UUID())
        
        check(XCTAssertEqual(detectCount, 1)) {
            sut.process(input: mockInput, onDetect: increase)
        }
    }
    
    func testAdAndContentPlaying() {
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                       adIsStreamPlaying: true,
                                                       sessionId: UUID())
        
        check(XCTAssertEqual(detectCount, 1)) {
            sut.process(input: mockInput, onDetect: increase)
        }
    }
    
    func testTwoVideos() {
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                       adIsStreamPlaying: true,
                                                       sessionId: UUID())
        let mockInput2 = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                        adIsStreamPlaying: true,
                                                        sessionId: UUID())
        
        check(XCTAssertEqual(detectCount, 2)) {
            sut.process(input: mockInput, onDetect: increase)
            sut.process(input: mockInput2, onDetect: increase)
        }
    }
    
    func testTwoVideosPlusBackToFirst() {
        
        let mockInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                       adIsStreamPlaying: false,
                                                       sessionId: UUID())
        let mockInput2 = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                        adIsStreamPlaying: false,
                                                        sessionId: UUID())
        check(XCTAssertEqual(detectCount, 3)) {
            sut.process(input: mockInput, onDetect: increase)
            sut.process(input: mockInput2, onDetect: increase)
            sut.process(input: mockInput, onDetect: increase)
        }
    }
    
    func testSessionIdTracking() {
        
        let allFalseInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: false,
                                                           adIsStreamPlaying: false,
                                                           sessionId: UUID())
        
        let contentPLayingInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                                 adIsStreamPlaying: false,
                                                                 sessionId: UUID())
        
        let contentPLayingInput2 = Detectors.ContextStarted.Input(contentIsStreamPlaying: true,
                                                                  adIsStreamPlaying: false,
                                                                  sessionId: UUID())
        
        let adPlayingInput = Detectors.ContextStarted.Input(contentIsStreamPlaying: false,
                                                            adIsStreamPlaying: true,
                                                            sessionId: UUID())
        
        check(XCTAssertEqual(detectCount, 0)) {
            sut.process(input: allFalseInput, onDetect: increase)
        }
        
        check(XCTAssertEqual(detectCount, 1)) {
            sut.process(input: contentPLayingInput, onDetect: increase)
            sut.process(input: contentPLayingInput, onDetect: increase)
            sut.process(input: contentPLayingInput, onDetect: increase)
        }
        
        check(XCTAssertEqual(detectCount, 2)) {
            sut.process(input: contentPLayingInput2, onDetect: increase)
            sut.process(input: contentPLayingInput2, onDetect: increase)
        }
        
        check(XCTAssertEqual(detectCount, 3)) {
            sut.process(input: adPlayingInput, onDetect: increase)
            sut.process(input: adPlayingInput, onDetect: increase)
        }
    }
    
    func testPlaybackUnavailble() {
        check(XCTAssertEqual(detectCount, 0)) {
            let unavailableInput = Detectors.ContextStarted.Input(playbackItem: nil, sessionId: UUID())
            sut.process(input: unavailableInput, onDetect: increase)
        }
    }
}
