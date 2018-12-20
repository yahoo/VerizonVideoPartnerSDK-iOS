//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK
@testable import PlayerCore

class VRMItemControllerTest: XCTestCase {
    
    let recorder = Recorder()
    
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
        
        vastItem = VRMCore.Item.vast(vastXML, metaInfo)
        urlItem = VRMCore.Item.url(url, metaInfo)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testStartItemsFetching() {
        let dispatch: (PlayerCore.Action) -> () = recorder.hook("testStartItemsFetching") { target, recorded -> Bool in
            switch(target, recorded) {
            case let ( VRMCore.StartItem.fetching(targetItem, targetUrl, _),
                       VRMCore.StartItem.fetching(recordedItem, recordedUrl, _) ):
                return targetUrl == recordedUrl && recordedItem == targetItem
            default: return false
            }
            }
        
        sut = VRMItemController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: Set([urlItem]))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemFetch(originalItem: urlItem, url: url))
        }
    }
    
    func testStartItemsParsing() {
        let dispatch: (PlayerCore.Action) -> () = recorder.hook("testStartItemsParsing") { target, recorded -> Bool in
            switch(target, recorded) {
            case let ( VRMCore.StartItem.parsing(targetItem, targetVast, _),
                       VRMCore.StartItem.parsing(recordedItem, recordedVast, _) ):
                return targetVast == recordedVast && recordedItem == targetItem
            default: return false
            }
            }
        
        sut = VRMItemController(dispatch: dispatch)
        
        recorder.record {
            sut.process(with: Set([vastItem]))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
    
    func testDoubleDispatch() {
        let dispatch: (PlayerCore.Action) -> () = recorder.hook("testDoubleDispatch") { targetAction, recordeAction -> Bool in
            switch(targetAction, recordeAction) {
            case let ( VRMCore.StartItem.parsing(targetItem, targetVast, _),
                       VRMCore.StartItem.parsing(recordedItem, recordedVast, _) ):
                return targetVast == recordedVast && recordedItem == targetItem
            default: return false
            }
            }
        
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
