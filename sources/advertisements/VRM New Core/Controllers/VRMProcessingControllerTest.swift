//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VRMProcessingControllerTest: XCTestCase {
    
    let maxRedirectCount = 3
    let recorder = Recorder()
    
    let selectInlineAdActionComparator = ActionComparator<VRMCore.SelectInlineItem> {
        $0.item == $1.item && $0.inlineVAST == $1.inlineVAST
    }
    let unwrapItemActionComparator = ActionComparator<VRMCore.UnwrapItem> {
        $0.item == $1.item && $0.url == $1.url
    }
    let wrapperErrorActionComparator = ActionComparator<VRMCore.TooManyIndirections> {
        $0.item == $1.item
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
                        mp4MediaFiles: [],
                        vpaidMediaFiles: [],
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
    
    func testSelectInlineModel() {
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          dispatch: recorder.hook("testSelectInlineModel", cmp: selectInlineAdActionComparator.compare))
        
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: inline)],
                        scheduledVRMItems: [:],
                        isMaxAdSearchTimeoutReached: false)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.selectInlineVAST(item: urlItem, inlineVAST: adModel))
        }
    }
    
    func testWrapperModel() {
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          dispatch: recorder.hook("testWrapperModel", cmp: unwrapItemActionComparator.compare))
        
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: wrapper)],
                        scheduledVRMItems: [urlItem: Set()],
                        isMaxAdSearchTimeoutReached: false)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.unwrapItem(item: urlItem, url: wrapperUrl))
        }
    }
    
    func testMaxAdSearchTime() {
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          dispatch: recorder.hook("testMaxAdSearchTime", cmp: unwrapItemActionComparator.compare))
        
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: wrapper)],
                        scheduledVRMItems: [:],
                        isMaxAdSearchTimeoutReached: true)
        }
        
        recorder.verify {}
    }
    
    func testMaxRedirectCount() {
        let queueWithTooManyWrappers = Set<ScheduledVRMItems.Candidate>([.init(source: urlItem.source),
                                                                         .init(source: .url(URL(string:"http://test1.com")!))])
        let parsingQueue: [VRMCore.Item: VRMParsingResult.Result] = [urlItem: .init(vastModel: wrapper)]
        
        let hook = recorder.hook("testMaxRedirectCount", cmp: wrapperErrorActionComparator.compare)
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount, dispatch: hook)
        
        
        recorder.record {
            sut.process(parsingResultQueue:parsingQueue,
                        scheduledVRMItems: [urlItem: queueWithTooManyWrappers],
                        isMaxAdSearchTimeoutReached: false)
            
            sut.process(parsingResultQueue: parsingQueue,
                        scheduledVRMItems: [urlItem: queueWithTooManyWrappers],
                        isMaxAdSearchTimeoutReached: false)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.tooManyIndirections(item: urlItem))
        }
    }
}
