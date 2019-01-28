//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore


class VRMSelectFinalResultControllerTest: XCTestCase {
    
    let recorder = Recorder()
    var sut: VRMSelectFinalResultController!
    var adModel1: PlayerCore.Ad.VASTModel!
    var adModel2: PlayerCore.Ad.VASTModel!
    
    var result1: VRMCore.Result!
    var result2: VRMCore.Result!
    
    var group: VRMCore.Group!
    
    override func setUp() {
        super.setUp()
        let comparator = ActionComparator<VRMCore.SelectFinalResult> {
            $0.item == $1.item && $0.inlineVAST == $1.inlineVAST
        }
        let dispatch = recorder.hook("hook", cmp: comparator.compare)
        sut = VRMSelectFinalResultController(dispatch: dispatch)
        
        adModel1 = .init(adVerifications: [],
                        videos: [],
                        clickthrough: nil,
                        adParameters: nil,
                        pixels: .init(),
                        id: "id1")
        
        adModel2 = .init(adVerifications: [],
                         videos: [],
                         clickthrough: nil,
                         adParameters: nil,
                         pixels: .init(),
                         id: "id2")
        let metaInfo = VRMCore.Item.MetaInfo(engineType: nil,
                                             ruleId: nil,
                                             ruleCompanyId: nil,
                                             vendor: "",
                                             name: nil,
                                             cpm: nil)
        let vastItem = VRMCore.Item(source: .vast(""), metaInfo: metaInfo)
        let urlItem = VRMCore.Item(source: .url(URL(string: "http://ad.com")!), metaInfo: metaInfo)
        
        result1 = VRMCore.Result(item: vastItem, inlineVAST: adModel1)
        result2 = VRMCore.Result(item: urlItem, inlineVAST: adModel2)
        group = VRMCore.Group(items: [result1.item, result2.item])
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    
    func testMaxAdSearchTime() {
        recorder.record {
            sut.process(processingResults: Set([result1, result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: true,
                        finalResult: nil,
                        topPriorityItem: nil)
        }
        
        recorder.verify {}
    }
    
    func testNoDispatchIfFinalResultPresent() {
        recorder.record {
            sut.process(processingResults: Set([result1, result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: result1,
                        topPriorityItem: nil)
        }
        
        recorder.verify {}
    }
    
    func testDispatchTopPriorityItem() {
        recorder.record {
            sut.process(processingResults: Set([result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: nil,
                        topPriorityItem: result1.item)
            
            sut.process(processingResults: Set([result2, result1]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: nil,
                        topPriorityItem: result1.item)
            
            sut.process(processingResults: Set([result2, result1]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: nil,
                        topPriorityItem: result1.item)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.selectFinalResult(item: result1.item,
                                                   inlineVAST: result1.inlineVAST))
        }
    }
    
    func testDispatchAfterSoftTimeout() {
        recorder.record {
            sut.process(processingResults: Set([result1, result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: nil,
                        topPriorityItem: nil)
            
            sut.process(processingResults: Set([result1, result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: result1,
                        topPriorityItem: nil)
            
            sut.process(processingResults: Set([result1, result2]),
                        currentGroup: group,
                        isMaxAdSearchTimeoutReached: false,
                        finalResult: nil,
                        topPriorityItem: nil)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.selectFinalResult(item: result1.item,
                                                   inlineVAST: result1.inlineVAST))
            sut.dispatch(VRMCore.selectFinalResult(item: result2.item,
                                                   inlineVAST: result2.inlineVAST))
        }
    }
}
