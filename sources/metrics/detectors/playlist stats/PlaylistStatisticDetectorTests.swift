//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
@testable import VerizonVideoPartnerSDK

class PlaylistStatisticDetectorTests: XCTestCase {
    let sut = Detectors.PlaylistStatistic()
    let id = UUID()
    let adID = UUID()
    
    func testNoReportWithoutCompletePlayback() {
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: UUID(),
                                 playbackDuration: 0,
                                 adHasDuration: false,
                                 adSessionID: UUID()))
    }
    
    func testEmptyReportWithCompletePlayback() {
        let result = sut.process(playing: false,
                                 completed: true,
                                 contentSessionID: UUID(),
                                 playbackDuration: 0,
                                 adHasDuration: false,
                                 adSessionID: UUID())
        
        XCTAssertEqual(result?.videosCount, 0)
        XCTAssertEqual(result?.time, 0)
    }
    
    func testSingleVideoPlayback() {
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 2,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 3,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 5,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 7,
                                 adHasDuration: false,
                                 adSessionID: adID))
        let result = sut.process(playing: true,
                                 completed: true,
                                 contentSessionID: id,
                                 playbackDuration: 10,
                                 adHasDuration: false,
                                 adSessionID: adID)
        
        XCTAssertEqual(result?.videosCount, 1)
        XCTAssertEqual(result?.time, 10)
    }
    
    func testReportForMultipleVideos() {
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 0,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 5,
                                 adHasDuration: false,
                                 adSessionID: adID))
        let newId = UUID()
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: newId,
                                 playbackDuration: 10,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: newId,
                                 playbackDuration: 15,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 0,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: false,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 5,
                                 adHasDuration: false,
                                 adSessionID: adID))
        let result = sut.process(playing: false,
                                 completed: true,
                                 contentSessionID: id,
                                 playbackDuration: 10,
                                 adHasDuration: false,
                                 adSessionID: adID)
        
        XCTAssertEqual(result?.videosCount, 3)
        XCTAssertEqual(result?.time, 20)
    }
    
    func testMultipleWithoutPause() {
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 0,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: UUID(),
                                 playbackDuration: 10,
                                 adHasDuration: false,
                                 adSessionID: adID))
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 10,
                                 adHasDuration: false,
                                 adSessionID: adID))
        let result = sut.process(playing: true,
                                 completed: true,
                                 contentSessionID: id,
                                 playbackDuration: 20,
                                 adHasDuration: false,
                                 adSessionID: adID)
        
        XCTAssertEqual(result?.videosCount, 3)
        XCTAssertEqual(result?.time, 30)
    }
    
    func testStatisticWithOneAd() {
        do {
            let result = sut.process(playing: true,
                                     completed: true,
                                     contentSessionID: id,
                                     playbackDuration: 0,
                                     adHasDuration: false,
                                     adSessionID: adID)
            XCTAssertEqual(result?.playedAds, 0)
        }
        
        do {
            let result = sut.process(playing: true,
                                     completed: true,
                                     contentSessionID: id,
                                     playbackDuration: 0,
                                     adHasDuration: true,
                                     adSessionID: adID)
            XCTAssertEqual(result?.playedAds, 1)
        }
    }
    
    func testStatisticWithTwoAds() {
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: id,
                                 playbackDuration: 30,
                                 adHasDuration: true,
                                 adSessionID: adID))
        let newAdId = UUID()
        XCTAssertNil(sut.process(playing: true,
                                 completed: false,
                                 contentSessionID: newAdId,
                                 playbackDuration: 30,
                                 adHasDuration: true,
                                 adSessionID: newAdId))
        let result = sut.process(playing: true,
                                 completed: true,
                                 contentSessionID: id,
                                 playbackDuration: 30,
                                 adHasDuration: true,
                                 adSessionID: newAdId)
        XCTAssertEqual(result?.playedAds, 2)
    }
    
    func testSessionTracking() {
        do {
            let result = sut.process(playing: true,
                                     completed: true,
                                     contentSessionID: id,
                                     playbackDuration: 30,
                                     adHasDuration: false,
                                     adSessionID: adID)
            XCTAssertEqual(result?.videosCount, 1)
        }
        
        let newId = UUID()
        
        do {
            let result = sut.process(playing: true,
                                     completed: true,
                                     contentSessionID: newId,
                                     playbackDuration: 30,
                                     adHasDuration: false,
                                     adSessionID: adID)
            XCTAssertEqual(result?.videosCount, 2)
        }
        
        do {
            let result = sut.process(playing: true,
                                     completed: true,
                                     contentSessionID: newId,
                                     playbackDuration: 30,
                                     adHasDuration: false,
                                     adSessionID: adID)
            XCTAssertEqual(result?.videosCount, 2)
        }
    }
}
