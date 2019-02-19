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
    let otherErrorActionComparator = ActionComparator<VRMCore.OtherError> {
        $0.item == $1.item
    }
    
    let wrapperUrl = URL(string: "http://test.com")!
    var wrapper: VRMCore.VASTModel!
    var adModel: PlayerCore.Ad.VASTModel!
    var vpaidInline: VRMCore.VASTModel!
    var emptyInline: VRMCore.VASTModel!
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
        let vpaidMediaFile = PlayerCore.Ad.VASTModel.VPAIDMediaFile(url: URL(string:"http://vpaid.com")!,
                                                                    scalable: true,
                                                                    maintainAspectRatio: true)
        let mp4MEdiaFile = PlayerCore.Ad.VASTModel.MP4MediaFile(url: URL(string:"http://mp4.com")!,
                                                                width: 1,
                                                                height: 1,
                                                                scalable: true,
                                                                maintainAspectRatio: true)
        wrapper = VRMCore.VASTModel.wrapper(.init(tagURL: wrapperUrl,
                                                  adVerifications: [],
                                                  pixels: .init()))
        adModel = .init(adVerifications: [],
                        mp4MediaFiles: [mp4MEdiaFile],
                        vpaidMediaFiles: [vpaidMediaFile],
                        skipOffset: .none,
                        clickthrough: nil,
                        adParameters: nil,
                        adProgress: [],
                        pixels: .init(),
                        id: nil)
        
        inline = .inline(adModel)
        emptyInline = .inline(.init(adVerifications: [],
                                    mp4MediaFiles: [],
                                    vpaidMediaFiles: [],
                                    skipOffset: .none,
                                    clickthrough: nil,
                                    adParameters: nil,
                                    adProgress: [],
                                    pixels: .init(),
                                    id: nil))
        vpaidInline = .inline(.init(adVerifications: [],
                                    mp4MediaFiles: [],
                                    vpaidMediaFiles: [vpaidMediaFile],
                                    skipOffset: .none,
                                    clickthrough: nil,
                                    adParameters: nil,
                                    adProgress: [],
                                    pixels: .init(),
                                    id: nil))
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
                                          isVPAIDAllowed: true,
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
                                          isVPAIDAllowed: true,
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
                                          isVPAIDAllowed: true,
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
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          isVPAIDAllowed: true,
                                          dispatch: hook)
        
        
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
    
    func testEmptyAdModel() {
        let hook = recorder.hook("testEmptyAdModel", cmp: otherErrorActionComparator.compare)
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          isVPAIDAllowed: true,
                                          dispatch: hook)
        
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: emptyInline)],
                        scheduledVRMItems: [urlItem: Set()],
                        isMaxAdSearchTimeoutReached: false)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.otherError(item: urlItem))
        }
    }
    
    func testNoAllowedVPAID() {
        let hook = recorder.hook("testNoAllowedVPAID", cmp: otherErrorActionComparator.compare)
        let sut = VRMProcessingController(maxRedirectCount: maxRedirectCount,
                                          isVPAIDAllowed: false,
                                          dispatch: hook)
        
        recorder.record {
            sut.process(parsingResultQueue: [urlItem: .init(vastModel: vpaidInline)],
                        scheduledVRMItems: [urlItem: Set()],
                        isMaxAdSearchTimeoutReached: false)
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.otherError(item: urlItem))
        }
    }
}
