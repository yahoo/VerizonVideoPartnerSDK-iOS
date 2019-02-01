//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class AdEngineRequestDetectorTest: XCTestCase {

    let firstCandidate = ScheduledVRMItems.Candidate(source: .vast(""))
    let secondCandidate = ScheduledVRMItems.Candidate(source: .vast(""))
    
    var firstMetainfo: VRMCore.Item.MetaInfo!
    var secondMetainfo: VRMCore.Item.MetaInfo!
    var firstItem: VRMCore.Item!
    var secondItem: VRMCore.Item!
    var detector: Detectors.AdEngineRequestDetector!
    
    override func setUp() {
        super.setUp()
        detector = Detectors.AdEngineRequestDetector()
        firstMetainfo = VRMCore.Item.MetaInfo(engineType: "engineType1",
                                         ruleId: "ruleId1",
                                         ruleCompanyId: "ruleCompanyId1",
                                         vendor: "vendor1",
                                         name: "name1",
                                         cpm: "cpm1")
        secondMetainfo = VRMCore.Item.MetaInfo(engineType: "engineType2",
                                              ruleId: "ruleId2",
                                              ruleCompanyId: "ruleCompanyId2",
                                              vendor: "vendor2",
                                              name: "name2",
                                              cpm: "cpm2")
        firstItem = VRMCore.Item(source: .vast(""), metaInfo: firstMetainfo)
        secondItem = VRMCore.Item(source: .vast(""), metaInfo: secondMetainfo)
    }
    
    func testEmptyDetect() {
        let result = detector.process(transactionId: "", scheduledItems: [:])
        XCTAssertTrue(result.isEmpty)
    }
    
    func testCorrectDetection() {
        let queue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [firstItem: Set([firstCandidate])]
        var result = detector.process(transactionId: "", scheduledItems: queue)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result[0].adInfo.engineType,    firstMetainfo.engineType)
        XCTAssertEqual(result[0].adInfo.ruleId,        firstMetainfo.ruleId)
        XCTAssertEqual(result[0].adInfo.ruleCompanyId, firstMetainfo.ruleCompanyId)
        XCTAssertEqual(result[0].adInfo.vendor,        firstMetainfo.vendor)
        XCTAssertEqual(result[0].adInfo.name,          firstMetainfo.name)
        XCTAssertEqual(result[0].adInfo.cpm,           firstMetainfo.cpm)
    }
    
    func testDoubleDetectSameCandidate() {
        let queue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [firstItem: Set([firstCandidate])]
        var result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertEqual(result.count, 1)
        
        result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testDetectingTwoCandidates() {
        let queue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [firstItem: Set([firstCandidate, secondCandidate])]
        var result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertEqual(result.count, 2)
        
        result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testDetectingTwoItems() {
        let queue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [firstItem: Set([firstCandidate]),
                                                                       secondItem: Set([secondCandidate])]
        var result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertEqual(result.count, 2)
        
        result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertTrue(result.isEmpty)
    }
    
    func testDetectNewCandidate() {
        var candidates = Set([firstCandidate])
        var queue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [firstItem: candidates]
        var result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertEqual(result.count, 1)
        
        candidates.insert(secondCandidate)
        queue[firstItem] = candidates
        
        result = detector.process(transactionId: "", scheduledItems: queue)
        XCTAssertEqual(result.count, 1)
    }
}
