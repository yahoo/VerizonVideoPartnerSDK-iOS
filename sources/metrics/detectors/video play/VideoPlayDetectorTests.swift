//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK

class VideoPlayDetectorTests: XCTestCase {
    
    func testNoReportWhenStreamIsNotPlaying() {
        let sut = Detectors.VideoPlay()
        do {
            let result = sut.process(dimensions: nil, isStreamPlaying: false, sessionID: UUID())
            XCTAssertNil(result)
        }
        
        do {
            let result = sut.process(dimensions: CGSize(width: 100, height: 100),
                                     isStreamPlaying: false,
                                     sessionID: UUID())
            XCTAssertNil(result)
        }
    }

    func testNoReportWhenStreamPlayingAndDimensionsAreNil() {
        let sut = Detectors.VideoPlay()
        let result = sut.process(dimensions: nil, isStreamPlaying: true, sessionID: UUID())
        XCTAssertNil(result)
    }
    
    func testNoReportWithTheSameSession() {
        let id = UUID()
        let sut = Detectors.VideoPlay(sessionID: id)
        let result = sut.process(dimensions: nil, isStreamPlaying: true, sessionID: id)
        XCTAssertNil(result)
    }
    
    func testReportOnEachNewSession() {
        let sut = Detectors.VideoPlay()
        
        do {
            let dimensions = CGSize(width: 50, height: 50)
            let result = sut.process(dimensions: dimensions,
                                     isStreamPlaying: true,
                                     sessionID: UUID())
            XCTAssertEqual(result?.size, dimensions)
        }
        
        do {
            let dimensions = CGSize(width: 100, height: 100)
            let result = sut.process(dimensions: CGSize(width: 100, height: 100),
                                     isStreamPlaying: true,
                                     sessionID: UUID())
            XCTAssertEqual(result?.size, dimensions)
        }
    }
}
