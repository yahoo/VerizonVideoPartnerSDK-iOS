//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FailoverDetectorsTests: XCTestCase {
    
    let adSessionID = UUID()
    var detector: Detectors.Failover!
    var group: VRMCore.Group!
    var response: VRMResponse!
    let item = VRMCore.Item(source: VRMCore.Item.Source.vast(""),
                            metaInfo: VRMCore.Item.MetaInfo.init(engineType: "",
                                                                 ruleId: "",
                                                                 ruleCompanyId: "",
                                                                 vendor: "",
                                                                 name: "",
                                                                 cpm: ""))
    
    override func setUp() {
        super.setUp()
        detector = Detectors.Failover()
        group = VRMCore.Group(items: [])
        response = VRMResponse(transactionId: "", slot: "", groups: [group])
    }
    
    
    func testResponseWithoutVRMResponse() {
        let result = detector.process(vrmResponse: nil,
                                       currentGroup: group,
                                       groupQueue: [],
                                       adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseAndNonEmptyGroupQueue() {
        let result = detector.process(vrmResponse: response,
                                      currentGroup: group,
                                      groupQueue: [group],
                                      adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseWithEmptyGroupQueue() {
        let result = detector.process(vrmResponse: response,
                                      currentGroup: group,
                                      groupQueue: [],
                                      adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    
    func testFailoverCase() {
        var result = detector.process(vrmResponse: response,
                                      currentGroup: group,
                                      groupQueue: [group],
                                      adSessionID: adSessionID)
        result = detector.process(vrmResponse: response,
                                  currentGroup: group,
                                  groupQueue: [],
                                  adSessionID: adSessionID)
        result = detector.process(vrmResponse: response,
                                  currentGroup: nil,
                                  groupQueue: [],
                                  adSessionID: adSessionID)
        XCTAssertTrue(result)
    }
    
    func testResponseWithNoAds() {
        let emptyResponse = VRMResponse(transactionId: "", slot: "", groups: [])
        var result = detector.process(vrmResponse: nil,
                                      currentGroup: nil,
                                      groupQueue: [],
                                      adSessionID: adSessionID)
        result = detector.process(vrmResponse: emptyResponse,
                                  currentGroup: nil,
                                  groupQueue: [],
                                  adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseWithMultipleAdSessions() {
        var result = detector.process(vrmResponse: response,
                                      currentGroup: group,
                                      groupQueue: [group],
                                      adSessionID: adSessionID)
        result = detector.process(vrmResponse: response,
                                  currentGroup: nil,
                                  groupQueue: [],
                                  adSessionID: adSessionID)
        XCTAssertTrue(result)
        
        let newSessionID = UUID()
        result = detector.process(vrmResponse: response,
                                      currentGroup: group,
                                      groupQueue: [group],
                                      adSessionID: newSessionID)
        result = detector.process(vrmResponse: response,
                                  currentGroup: nil,
                                  groupQueue: [],
                                  adSessionID: newSessionID)
        XCTAssertTrue(result)
    }
}
