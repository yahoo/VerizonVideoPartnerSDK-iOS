//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FinishVRMGroupProcessingControllerTest: XCTestCase {

    let recorder = Recorder()
    
    var sut: FinishVRMGroupProcessingController!
    
    let url = URL(string: "http://test.com")!
    let vastXML = "VAST String"
    var vastItem: VRMCore.Item!
    var urlItem: VRMCore.Item!
    var group: VRMCore.Group!

    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.FinishCurrentGroupProcessing> {_,_ in
            return true
        }
        let dispatcher = recorder.hook("hook", cmp: actionComparator.compare)
        sut = FinishVRMGroupProcessingController(dispatch: dispatcher)
        
        let metaInfo = VRMCore.Item.MetaInfo(engineType: "engineType",
                                             ruleId: "ruleId",
                                             ruleCompanyId: "ruleCompanyId",
                                             vendor: "vendor",
                                             name: "name",
                                             cpm: "cpm")
        
        vastItem = VRMCore.Item(source: .vast(vastXML), metaInfo: metaInfo)
        urlItem = VRMCore.Item(source: .url(url), metaInfo: metaInfo)
        group = VRMCore.Group(items: [urlItem, vastItem])
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testDoubleDispatchHardTimeout() {
        recorder.record {
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [])
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testDoubleDispatchMaxAdSearchTime() {
        recorder.record {
            sut.process(with: .none,
                        isMaxSearchTimeReached: true,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [])
            
            sut.process(with: .none,
                        isMaxSearchTimeReached: true,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testDoubleDispatchAllItemsInGroupAlreadyProcessed() {
        recorder.record {
            sut.process(with: .none,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [urlItem],
                        processedItems: [vastItem])
            
            sut.process(with: .none,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [urlItem],
                        processedItems: [vastItem])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testNoDispatch() {
        recorder.record {
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [])
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [urlItem],
                        processedItems: [])
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: [],
                        processedItems: [urlItem])
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: true,
                        currentGroup: nil,
                        erroredItems: [],
                        processedItems: [])
        }
        
        recorder.verify {
        }
    }
}
