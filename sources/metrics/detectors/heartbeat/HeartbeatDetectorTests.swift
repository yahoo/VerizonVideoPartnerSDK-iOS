//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK

class HeartbeatDetectorTests: XCTestCase {
    static let emptyStallRecordSet: [Player.Properties.PlayerSession.Playback.StallRecord] = []
    
    func testNoDetection() {
        let detector = Detectors.Heartbeat()
        
        XCTAssertNil(detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                      playbackDuration: 0,
                                      isLiveVideo: false,
                                      dimensions: .zero))
        XCTAssertNil(detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                      playbackDuration: 10,
                                      isLiveVideo: false,
                                      dimensions: .zero))
        XCTAssertNil(detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                      playbackDuration: 20,
                                      isLiveVideo: false,
                                      dimensions: .zero))
        XCTAssertNil(detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                      playbackDuration: 30,
                                      isLiveVideo: false,
                                      dimensions: .zero))
    }

    static let stallRecordSet1 = [Player.Properties.PlayerSession.Playback.StallRecord(duration: 5,
                                                                                       timestamp: 3.5)]
    
    static let stallRecordSet2 = stallRecordSet1 + [.init(duration: 10,
                                                          timestamp: 20),
                                                    .init(duration: 20,
                                                          timestamp: 39.9),
                                                    .init(duration: 20,
                                                          timestamp: 40.1)]
    
    func testDetection() {
        let detector = Detectors.Heartbeat()
        
        var result = detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                      playbackDuration: 0,
                                      isLiveVideo: true,
                                      dimensions: .zero)
        
        result = detector.process(stallRecords: HeartbeatDetectorTests.emptyStallRecordSet,
                                  playbackDuration: 15,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        
        XCTAssertNil(result)
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet1,
                                  playbackDuration: 20,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.dimensions, .zero)
        XCTAssertEqual(result?.totalStallTime, 5)
        
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet1,
                                  playbackDuration: 20.5,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNil(result)
        
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet2,
                                  playbackDuration: 20.7,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNil(result)
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet2,
                                  playbackDuration: 20.9,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNil(result)
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet2,
                                  playbackDuration: 21,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNil(result)
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet2,
                                  playbackDuration: 30,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNil(result)
        
        result = detector.process(stallRecords: HeartbeatDetectorTests.stallRecordSet2,
                                  playbackDuration: 40,
                                  isLiveVideo: true,
                                  dimensions: .zero)
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.dimensions, .zero)
        XCTAssertEqual(result?.totalStallTime, 20)
    }
    
    func testTotalStallDuration() {
        var result = totalStallDuration(from: HeartbeatDetectorTests.emptyStallRecordSet,
                                        playbackDuration: 0,
                                        interval: 0)
        XCTAssertEqual(result, 0)
        result = totalStallDuration(from: HeartbeatDetectorTests.stallRecordSet2,
                                    playbackDuration: 0,
                                    interval: 20)
        XCTAssertEqual(result, 15)
        
        result = totalStallDuration(from: HeartbeatDetectorTests.stallRecordSet2,
                                    playbackDuration: 19,
                                    interval: 20)
        XCTAssertEqual(result, 15)
        
        result = totalStallDuration(from: HeartbeatDetectorTests.stallRecordSet1,
                                    playbackDuration: 20,
                                    interval: 20)
        XCTAssertEqual(result, 5)
        
        result = totalStallDuration(from: HeartbeatDetectorTests.stallRecordSet2,
                                    playbackDuration: 30,
                                    interval: 20)
        XCTAssertEqual(result, 30)
    }
}
