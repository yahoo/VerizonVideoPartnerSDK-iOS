//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FailoverDetectorsTests: XCTestCase {
    
    let adRequestId = UUID()
    var detector: Detectors.Failover!
    
    override func setUp() {
        super.setUp()
        detector = Detectors.Failover()
    }
    
    func testResponseAndNonEmptyGroupQueue() {
        let result = detector.process(isVRMResponseGroupsEmpty: false,
                                      isCurrentVRMGroupEmpty: false,
                                      isVRMGroupsQueueEmpty: false,
                                      adSessionId: adRequestId)
        XCTAssertFalse(result)
    }
    func testResponseWithEmptyGroupQueue() {
        let result = detector.process(isVRMResponseGroupsEmpty: false,
                                      isCurrentVRMGroupEmpty: false,
                                      isVRMGroupsQueueEmpty: true,
                                      adSessionId: adRequestId)
        XCTAssertFalse(result)
    }
    
    func testFailoverCase() {
        let result = detector.process(isVRMResponseGroupsEmpty: false,
                                  isCurrentVRMGroupEmpty: true,
                                  isVRMGroupsQueueEmpty: true,
                                  adSessionId: adRequestId)
        XCTAssertTrue(result)
    }
    
    func testResponseWithNoAds() {
        let result = detector.process(isVRMResponseGroupsEmpty: true,
                                      isCurrentVRMGroupEmpty: true,
                                      isVRMGroupsQueueEmpty: true,
                                      adSessionId: adRequestId)
        XCTAssertFalse(result)
    }
    func testResponseWithMultipleAdSessions() {
        var result = detector.process(isVRMResponseGroupsEmpty: false,
                                      isCurrentVRMGroupEmpty: true,
                                      isVRMGroupsQueueEmpty: true,
                                      adSessionId: adRequestId)
        XCTAssertTrue(result)
        
        let newRequestId = UUID()
        result = detector.process(isVRMResponseGroupsEmpty: false,
                                  isCurrentVRMGroupEmpty: true,
                                  isVRMGroupsQueueEmpty: true,
                                  adSessionId: newRequestId)
        XCTAssertTrue(result)
    }
}
