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
    var adModel: PlayerCore.Ad.VASTModel!
    var result: VRMCore.Result!
    
    override func setUp() {
        super.setUp()
        let actionComparator = ActionComparator<VRMCore.FinishCurrentGroupProcessing> { _,_ in
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
        
        adModel = .init(adVerifications: [],
                        mp4MediaFiles: [],
                        vpaidMediaFiles: [],
                        skipOffset: .none,
                        clickthrough: nil,
                        adParameters: nil,
                        adProgress: [],
                        pixels: .init(),
                        id: "id1")
        result = VRMCore.Result(item: urlItem, inlineVAST: adModel)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testTriedAllProcessedItems() {
        recorder.record {
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(),
                        processedItems: Set([result.item]),
                        finalResult: nil)
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(),
                        processedItems: Set([result.item]),
                        finalResult: result)
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(),
                        processedItems: Set([result.item]),
                        finalResult: nil)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testDispatchMaxAdSearchTime() {
        recorder.record {
            sut.process(with: .soft,
                        isMaxSearchTimeReached: true,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([urlItem]),
                        finalResult: nil)
            
            group = VRMCore.Group(items: [vastItem, urlItem])
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([urlItem]),
                        finalResult: nil)
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([urlItem]),
                        finalResult: nil)
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: true,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([urlItem]),
                        finalResult: result)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testDoubleDispatchAllItemsInGroupAlreadyFailed() {
        recorder.record {
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(group.items),
                        processedItems: Set(),
                        finalResult: nil)
            
            sut.process(with: .soft,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(group.items),
                        processedItems: Set(),
                        finalResult: nil)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.finishCurrentGroupProcessing())
        }
    }
    
    func testNoDispatch() {
        recorder.record {
            sut.process(with: .none,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set(),
                        processedItems: Set(),
                        finalResult: nil)
            
            sut.process(with: .none,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([result.item]),
                        finalResult: nil)
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([result.item]),
                        finalResult: nil)
            
            sut.process(with: .hard,
                        isMaxSearchTimeReached: false,
                        currentGroup: group,
                        erroredItems: Set([vastItem]),
                        processedItems: Set([result.item]),
                        finalResult: result)
        }
        
        recorder.verify {
        }
    }
}
