//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import PlayerCore
import SafariServices
@testable import VerizonVideoPartnerSDK

class AdClickthroughWorkerTests: XCTestCase {
    let recorder = Recorder()
    
    let testURL = URL(string: "http://")!
    let controller = SFSafariViewController(url: URL(string: "http://")!)
    let mp4Creative = AdCreative.MP4(url: URL(string: "http://")!,
                                     clickthrough: URL(string: "http://")!,
                                     pixels: AdPixels(),
                                     id: nil,
                                     width: 10,
                                     height: 10,
                                     scalable: false,
                                     maintainAspectRatio: true)
    let vpaidCreative = AdCreative.VPAID(url: URL(string: "http://")!,
                                         adParameters: "",
                                         clickthrough: URL(string: "http://")!,
                                         pixels: AdPixels(),
                                         id: "")
    let vpaidCreativeWithoutCllick = AdCreative.VPAID(url: URL(string: "http://")!,
                                                      adParameters: "",
                                                      clickthrough: nil,
                                                      pixels: AdPixels(),
                                                      id: "")
    
    var sut: PlayerViewController.AdClickthroughWorker!
    
    override func setUp() {
        let showSafariHook = recorder.hook("showSafariHook")
        sut = PlayerViewController.AdClickthroughWorker(
            showSafari: { _, _ in
                showSafariHook()
        },
            safariFinishHandler: recorder.hook("finishSafariHook") { rcd, cmp -> Bool in
                return cmp == rcd
        })
        super.setUp()
    }
    
    func testMP4ClickThrough() {
        recorder.record {
            sut.process(isClickThroughToggled: false,
                        vpaidClickThroughURL: nil,
                        mp4AdCreative: mp4Creative,
                        vpaidAdCreative: nil)
        }
        recorder.verify {
        }
        
        recorder.record {
            sut.process(isClickThroughToggled: true,
                        vpaidClickThroughURL: nil,
                        mp4AdCreative: mp4Creative,
                        vpaidAdCreative: nil)
        }
        recorder.verify {
            sut.showSafari(testURL, sut)
        }

        recorder.record {
            sut.safariViewControllerDidFinish(controller)
        }
        recorder.verify {
            sut.safariFinishHandler(sut.isAdVPAID)
        }
    }
    
    func testVPAIDClickThrough() {
        recorder.record {
            sut.process(isClickThroughToggled: false,
                        vpaidClickThroughURL: testURL,
                        mp4AdCreative: nil,
                        vpaidAdCreative: vpaidCreative)
        }
        recorder.verify {
        }
        
        recorder.record {
            sut.process(isClickThroughToggled: true,
                        vpaidClickThroughURL: nil,
                        mp4AdCreative: nil,
                        vpaidAdCreative: vpaidCreative)
        }
        recorder.verify {
            sut.showSafari(testURL, sut)
        }
        
        recorder.record {
            sut.safariViewControllerDidFinish(controller)
        }
        recorder.verify {
            sut.safariFinishHandler(sut.isAdVPAID)
        }
    }
    
    
    func testVPAIDClickThroughFromItem() {
        recorder.record {
            sut.process(isClickThroughToggled: true,
                        vpaidClickThroughURL: testURL,
                        mp4AdCreative: nil,
                        vpaidAdCreative: vpaidCreativeWithoutCllick)
        }
        recorder.verify {
            sut.showSafari(testURL, sut)
        }
    }
    
    func testVPAIDWithoutClickURL() {
        recorder.record {
            sut.process(isClickThroughToggled: true,
                        vpaidClickThroughURL: nil,
                        mp4AdCreative: nil,
                        vpaidAdCreative: vpaidCreativeWithoutCllick)
        }
        recorder.verify {
            sut.safariFinishHandler(sut.isAdVPAID)
        }
    }
    
}
