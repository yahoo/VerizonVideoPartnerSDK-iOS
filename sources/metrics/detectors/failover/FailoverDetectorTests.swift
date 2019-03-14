//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FailoverDetectorsTests: XCTestCase {
    
    var detector: Detectors.Failover!
    var adSessionID: UUID!
    let item = VRMCore.Item(source: VRMCore.Item.Source.vast(""),
                            metaInfo: VRMCore.Item.MetaInfo.init(engineType: "",
                                                                 ruleId: "",
                                                                 ruleCompanyId: "",
                                                                 vendor: "",
                                                                 name: "",
                                                                 cpm: ""))
    
    override func setUp() {
        super.setUp()
        adSessionID = UUID()
        detector = Detectors.Failover()
    }
    
    
    func testResponseWithoutVRMResponse() {
        let result = detector.process(vrmResponse: nil, adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseWithOneNonEmptyGroup() {
        let vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [VRMCore.Group(items: [item])])
        let result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseWithOneEmptyGroup() {
        let vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [VRMCore.Group(items: [])])
        let result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    func testResponseWithoutGroups() {
        var vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [VRMCore.Group(items: [])])
        var result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [])
        result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        XCTAssertTrue(result)
    }
    func testResponseWithoutGroupsTwoInARow() {
        var vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [VRMCore.Group(items: [])])
        var result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [])
        result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [])
        result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
    
    func testResponseWithNoAds() {
        let vrmResponse = VRMResponse(transactionId: "", slot: "", groups: [])
        var result = detector.process(vrmResponse: nil, adSessionID: adSessionID)
        result = detector.process(vrmResponse: vrmResponse, adSessionID: adSessionID)
        XCTAssertFalse(result)
    }
}
