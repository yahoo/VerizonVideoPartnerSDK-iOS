//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
@testable import VerizonVideoPartnerSDK

class ThreeSecPlaybackDetectorTests: XCTestCase {
    
    let stallRecordSet = [Player.Properties.PlayerSession.Playback.StallRecord(duration: 5, timestamp: 0.5)]
    
    private func check(_ assertion: @autoclosure () -> (), after code: () -> ()) {
        code()
        assertion()
    }
    
    func testNoDetections() {
        let sut = Detectors.ThreeSecondsPlayback()
        
        var result: Detectors.ThreeSecondsPlayback.Result?
        
        check(XCTAssertNil(result)) {
            result = sut.process(input: .init(stallRecords: stallRecordSet,
                                              time: 0,
                                              sessionId: UUID(),
                                              playbackDuration: 0))
        }
        check(XCTAssertNil(result)) {
            result = sut.process(input: .init(stallRecords: stallRecordSet,
                                              time: 0,
                                              sessionId: UUID(),
                                              playbackDuration: 2))
        }
        check(XCTAssertNil(result)) {
            result = sut.process(input: .init(stallRecords: stallRecordSet,
                                              time: 0,
                                              sessionId: UUID(),
                                              playbackDuration: 2.5))
        }
    }
    
    
    func testMultipleDetections() {
        let sut = Detectors.ThreeSecondsPlayback()
        var results: [Detectors.ThreeSecondsPlayback.Result] = []
        let id = UUID()
        
        check(XCTAssertEqual(results.count, 0)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 0)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 2)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 2.5)).map { results.append($0) }
        }
        
        check(XCTAssertEqual(results.count, 1)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 3.5)).map { results.append($0) }
        }
        
        check(XCTAssertEqual(results.count, 1)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 4)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: id,
                                     playbackDuration: 5)).map { results.append($0) }
        }
        
        let nextId = UUID()
        check(XCTAssertEqual(results.count, 1)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 0)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 2)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 2.5)).map { results.append($0) }
        }
        
        check(XCTAssertEqual(results.count, 2)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 3.5)).map { results.append($0) }
        }
        
        check(XCTAssertEqual(results.count, 2)) {
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 4)).map { results.append($0) }
            sut.process(input: .init(stallRecords: stallRecordSet,
                                     time: 0,
                                     sessionId: nextId,
                                     playbackDuration: 5)).map { results.append($0) }
        }
    }
    
    func testStallValue() {
        
        let sut = Detectors.ThreeSecondsPlayback()
        var result: Detectors.ThreeSecondsPlayback.Result?
        let playbackDuration = 3.0
        
        check(XCTAssertEqual(result?.stallDuration, 5)) {
            result = sut.process(input: .init(stallRecords: stallRecordSet,
                                              time: 0,
                                              sessionId: UUID(),
                                              playbackDuration: playbackDuration))
        }
    }
}
