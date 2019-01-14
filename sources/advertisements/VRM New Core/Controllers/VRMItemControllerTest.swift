//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMItemControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let parseActionComparator = ActionComparator<VRMCore.StartItemParsing> {
        $0.vastXML == $1.vastXML && $0.originalItem == $1.originalItem
    }
    
    let wrapperErrorActionComparator = ActionComparator<VRMCore.TooManyIndirections> {
        $0.item == $1.item
    }
    
    let fetchActionComparator = ActionComparator<VRMCore.StartItemFetch> {
        $0.url == $1.url && $0.originalItem == $1.originalItem
    }
    
    let maxRedirectCount = 2
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
        
        sut = VRMItemController(maxRedirectCount: maxRedirectCount, dispatch: dispatch)
        
        recorder.record {
            sut.process(with: [urlItem: Set([.init(source: urlItem.source)])])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemFetch(originalItem: urlItem, url: url))
        }
    }
    
    func testStartItemsParsing() {
        let dispatch = recorder.hook("testStartItemsParsing", cmp: parseActionComparator.compare)
        
        sut = VRMItemController(maxRedirectCount: maxRedirectCount, dispatch: dispatch)
        
        recorder.record {
            sut.process(with: [vastItem: Set([.init(source: vastItem.source)])])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
    
    func testDoubleDispatch() {
        let dispatch = recorder.hook("testDoubleDispatch", cmp: parseActionComparator.compare)
        
        sut = VRMItemController(maxRedirectCount: maxRedirectCount, dispatch: dispatch)
        
        recorder.record {
            let scheduledQueue: [VRMCore.Item: Set<ScheduledVRMItems.Candidate>] = [vastItem: Set(arrayLiteral: .init(source: vastItem.source))]
            sut.process(with: scheduledQueue)
            sut.process(with: scheduledQueue)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
    
    func testProcessWrapper() {
        var compare = parseActionComparator.compare
        let dispatch = recorder.hook("testProcessWrapper", cmp: { compare($0,$1) })
        
        sut = VRMItemController(maxRedirectCount: maxRedirectCount, dispatch: dispatch)
        let first = ScheduledVRMItems.Candidate(source: vastItem.source)
        let second = ScheduledVRMItems.Candidate(source: .url(url))
        
        recorder.record {
            sut.process(with: [vastItem: Set([first])])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
        
        compare = fetchActionComparator.compare
        
        recorder.record {
            sut.process(with: [vastItem: Set([first, second])])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemFetch(originalItem: vastItem, url: url))
        }
    }
    
    func testMaxRedirectAndNextGroupProcess() {
        var compare = wrapperErrorActionComparator.compare
        let dispatch = recorder.hook("testMaxRedirect", cmp: { compare($0,$1) })
        
        sut = VRMItemController(maxRedirectCount: maxRedirectCount, dispatch: dispatch)
        
        let queueWithTooManyWrappers = Set<ScheduledVRMItems.Candidate>([.init(source: urlItem.source),
                                                                         .init(source: .url(URL(string:"http://test1.com")!)),
                                                                         .init(source: .url(URL(string:"http://test2.com")!))])
        recorder.record {
            sut.process(with: [urlItem: queueWithTooManyWrappers])
            sut.process(with: [urlItem: queueWithTooManyWrappers])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.tooManyIndirections(item: urlItem))
        }
        
        let correctQueue = Set<ScheduledVRMItems.Candidate>([.init(source: vastItem.source)])
        compare = parseActionComparator.compare
        
        recorder.record {
            sut.process(with: [urlItem: queueWithTooManyWrappers,
                               vastItem: correctQueue])
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: vastItem, vastXML: vastXML))
        }
    }
}
