//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FetchVRMItemControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let parseActionComparator = ActionComparator<VRMCore.StartItemParsing> {
        $0.vastXML == $1.vastXML && $0.originalItem == $1.originalItem
    }
    let failedFetchActionCompare = ActionComparator<VRMCore.FetchingError> {
        $0.originalItem == $1.originalItem
    }
    var sut: FetchVRMItemController!
    
    let url = URL(string: "http://test.com")!
    let vastXML = "VAST String"
    var urlItem: VRMCore.Item!
    var fetchCandidate: VRMFetchItemQueue.Candidate!

    
    override func setUp() {
        super.setUp()
        let metaInfo = VRMCore.Item.MetaInfo(engineType: "engineType",
                                             ruleId: "ruleId",
                                             ruleCompanyId: "ruleCompanyId",
                                             vendor: "vendor",
                                             name: "name",
                                             cpm: "cpm")
        
        urlItem = VRMCore.Item(source: .url(url), metaInfo: metaInfo)
        fetchCandidate = VRMFetchItemQueue.Candidate(parentItem: urlItem,
                                                          url: url)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testSuccessfulFetch() {
        let dispatch = recorder.hook("testSuccessfulFetch", cmp: parseActionComparator.compare)
        
        sut = FetchVRMItemController(dispatch: dispatch,
                                     fetchUrl: { url in
                                        return Future(value: .value(self.vastXML))
        })
        
        recorder.record {
            sut.process(with: Set(arrayLiteral: fetchCandidate))
            sut.process(with: Set(arrayLiteral: fetchCandidate))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.startItemParsing(originalItem: urlItem, vastXML: vastXML))
        }
    }
    
    func testErrorFetch() {
        struct TestError: Error {}
        let dispatch = recorder.hook("testErrorFetch", cmp: failedFetchActionCompare.compare)
        
        sut = FetchVRMItemController(dispatch: dispatch,
                                     fetchUrl: { url in
                                        return Future(value: .error(TestError()))
        })
        
        recorder.record {
            sut.process(with: Set(arrayLiteral: fetchCandidate))
            sut.process(with: Set(arrayLiteral: fetchCandidate))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.failedItemFetch(originalItem: urlItem))
        }
    }
}
