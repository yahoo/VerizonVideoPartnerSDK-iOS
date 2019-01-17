//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMProcessingControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let timeoutActionComparator = ActionComparator<VRMCore.TimeoutError> {
        $0.item == $1.item
    }
    let selectInlineAdActionComparator = ActionComparator<VRMCore.SelectInlineItem> {
        $0.originalItem == $1.originalItem && $0.inlineVAST == $1.inlineVAST
    }
    let unwrapItemActionComparator = ActionComparator<VRMCore.UnwrapItem> {
        $0.item == $1.item && $0.url == $1.url
    }
    
    let wrapperUrl = URL(string: "http://test.com")!
    var wrapper: VRMCore.VASTModel!
    var adModel: PlayerCore.Ad.VASTModel!
    var inline: VRMCore.VASTModel!
    var vastItem: VRMCore.Item!
    var urlItem: VRMCore.Item!
    
    override func setUp() {
        super.setUp()
        let metaInfo = VRMCore.Item.MetaInfo(engineType: nil,
                                             ruleId: nil,
                                             ruleCompanyId: nil,
                                             vendor: "",
                                             name: nil,
                                             cpm: nil)
        wrapper = VRMCore.VASTModel.wrapper(.init(tagURL: wrapperUrl,
                                                  adVerifications: [],
                                                  pixels: .init()))
        adModel = .init(adVerifications: [],
                        mediaFiles: [],
                        clickthrough: nil,
                        adParameters: nil,
                        pixels: .init(),
                        id: nil)
        inline = VRMCore.VASTModel.inline(adModel)
        vastItem = VRMCore.Item(source: .vast(""), metaInfo: metaInfo)
        urlItem = VRMCore.Item(source: .url(URL(string: "http://ad.com")!), metaInfo: metaInfo)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testTimeoutItemAndDoublDispatch() {
        let sut = VRMProcessingController(dispatch: recorder.hook("testTimeoutItem", cmp: timeoutActionComparator.compare))
        
        recorder.record {
            let result = VRMParsingResult.Result(vastModel: inline)
            sut.process(parsingResultQueue: [vastItem: result],
                        currentGroup: nil)
            sut.process(parsingResultQueue: [vastItem: result],
                        currentGroup: nil)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.timeoutError(item: vastItem))
        }
    }
    
    func testItemFromAnotherGroup() {
        let sut = VRMProcessingController(dispatch: recorder.hook("testItemFromAnotherGroup", cmp: timeoutActionComparator.compare))
        
        let group = VRMCore.Group(items: [urlItem])
        recorder.record {
            sut.process(parsingResultQueue: [vastItem: .init(vastModel: inline)],
                        currentGroup: group)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.timeoutError(item: vastItem))
        }
    }
    
    func testSelectInlineModel() {
        let sut = VRMProcessingController(dispatch: recorder.hook("testSelectInlineModel",
                                                                  cmp: selectInlineAdActionComparator.compare))
        
        let group = VRMCore.Group(items: [urlItem])
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: inline)],
                        currentGroup: group)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.selectInlineVAST(originalItem: urlItem, inlineVAST: adModel))
        }
    }
    
    func testWrapperModel() {
        let sut = VRMProcessingController(dispatch: recorder.hook("testWrapperModel",
                                                                  cmp: unwrapItemActionComparator.compare))
        
        let group = VRMCore.Group(items: [urlItem])
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: wrapper)],
                        currentGroup: group)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.unwrapItem(item: urlItem, url: wrapperUrl))
        }
    }
}
