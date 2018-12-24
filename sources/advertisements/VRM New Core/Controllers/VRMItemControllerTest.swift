//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK
@testable import PlayerCore

class VRMItemControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let parseActionComparator = ActionComparator<VRMCore.StartItemParsing> {
        $0.vastXML == $1.vastXML && $0.originalItem == $1.originalItem
    }
    
    let fetchActionComparator = ActionComparator<VRMCore.StartItemFetch> {
        $0.url == $1.url && $0.originalItem == $1.originalItem
    }
    
    let url = URL(string: "http://test.com")!
    let vastXML = "VAST String"
    var vastItem: VRMCore.Item!
    var urlItem: VRMCore.Item!
    var sut: VRMItemController!
    
    
    override func setUp() {
        super.setUp()
        let metaInfo = VRMCore.Item.MetaInfo(engineType: "engineType",
                                             ruleId: "ruleId",
                                             ruleCompanyId: "ruleCompanyId",
                                             vendor: "vendor",
                                             name: "name",
                                             cpm: "cpm")
        
        vastItem = VRMCore.Item(source: .vast(vastXML), metaInfo: metaInfo)
        urlItem = VRMCore.Item(source: .url(url), metaInfo: metaInfo)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testStartItemsFetching() {
        let dispatch = recorder.hook("compareFetchActions", cmp: fetchActionComparator.compare)
        
        sut = VRMItemController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: Set([urlItem]))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemFetch(originalItem: urlItem, url: url))
        }
    }
    
    func testStartItemsParsing() {
        let dispatch = recorder.hook("testStartItemsParsing", cmp: parseActionComparator.compare)
        
        sut = VRMItemController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: Set([vastItem]))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
    
    func testDoubleDispatch() {
        let dispatch = recorder.hook("testDoubleDispatch", cmp: parseActionComparator.compare)
        
        sut = VRMItemController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: Set([vastItem]))
            sut.process(with: Set([vastItem]))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
}
