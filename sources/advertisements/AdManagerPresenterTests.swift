//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class AdManagerPresenterTests: QuickSpec {
    
    override func spec() { //swiftlint:disable:this function_body_length
        let targetURL = URL(string: "http://test.com")!
        describe("ad manager") {
            let uuid1 = UUID()
            let uuid2 = UUID()
            let recorder = Recorder()
            beforeEach { recorder.clean() }
            
            let requestString: (URL) -> Void = recorder.hook("request string") { $0 == $1 }
            var promise: Future<String?>.Promise?
            beforeEach { promise = nil }
            var adID: UUID? = nil
            var adManager: AdManager<String>!
            beforeEach {
                recorder.record {
                    adManager = AdManager(
                        requestAd: {
                            requestString($0)
                            return Future { promise = $0 } },
                        dispatcher: { action in
                            if let request = action as? AdRequest {
                                adID = request.id
                            } else {
                                XCTFail("Expecting AdRequest with advertisement ID!")
                            }
                    })
                    adManager?.actions.dropPreroll = recorder.hook("drop preroll")
                    adManager?.actions.startPreroll = recorder.hook("start preroll")
                }
            }
            
            it("should not fire actions") {
                recorder.verify {}
            }
            
            it("should start preroll") {
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 0
                    adManager.props.sessionID = uuid1
                    adManager.props.url = targetURL
                    adManager.props.isStarted = true
                }
                recorder.verify {
                    requestString(targetURL)
                }
                
                guard let promise = promise else { return XCTFail() }
                let url = "http://test.com"
                recorder.record {
                    promise(url)
                }
                
                recorder.verify {
                    adManager.actions.startPreroll(url)
                }
                
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 1
                    adManager.props.sessionID = uuid1
                }
                
                recorder.verify {}
            }
            
            it("should drop preroll") {
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 0
                    adManager.props.sessionID = uuid1
                    adManager.props.url = targetURL
                    adManager.props.isStarted = true
                }
                recorder.verify {
                    requestString(targetURL)
                }
                
                guard let promise = promise else { return XCTFail() }
                recorder.record {
                    promise(nil)
                }
                
                recorder.verify {
                    adManager.actions.dropPreroll(adID!)
                }
                
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 1
                    adManager.props.sessionID = uuid1
                }
                
                recorder.verify {}
            }
            
            it("should reuse preroll request") {
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 0
                    adManager.props.sessionID = uuid1
                    adManager.props.isStarted = true
                    adManager.props.url = targetURL
                }
                
                recorder.verify {
                    requestString(targetURL)
                }
                
                guard let testCallback = promise else { return XCTFail() }
                
                recorder.record {
                    adManager.props.preroll.count = 1
                    adManager.props.preroll.number = 0
                    adManager.props.sessionID = uuid2
                    adManager.props.url = targetURL
                }
                
                recorder.verify {
                    requestString(targetURL)
                }
                
                guard let anotherCallback = promise else { return XCTFail() }
                let url = "http://test.com"
                
                recorder.record {
                    testCallback(url)
                }
                
                recorder.verify {}
                
                recorder.record {
                    anotherCallback(url)
                }
                
                recorder.verify {
                    adManager.actions.startPreroll(url)
                }
            }
            
            it("should reuse preroll request") {
                recorder.record {
                    adManager.props.preroll.count = 2
                    adManager.props.preroll.number = 0
                    adManager.props.sessionID = uuid1
                    adManager.props.isStarted = true
                    adManager.props.url = targetURL
                }
                
                recorder.verify {
                    requestString(targetURL)
                }
                
                recorder.record {
                    adManager.props.preroll.count = 2
                    adManager.props.preroll.number = 1
                    adManager.props.sessionID = uuid1
                }
                
                recorder.verify {}
                
                
                guard let testCallback = promise else { return XCTFail() }
                let url = "http://test.com"
                
                recorder.record {
                    testCallback(url)
                }
                
                recorder.verify {
                    adManager.actions.startPreroll(url)
                }
            }

        }
    }
}
