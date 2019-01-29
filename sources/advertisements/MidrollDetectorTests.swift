//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class MidrollDetectorTests: QuickSpec {
    override func spec() { //swiftlint:disable:this function_body_length
        describe("midroll playing") {
            var midrollDetector: MidrollDetector!
            let recorder = Recorder()
            beforeEach { recorder.clean() }
            var model: PlayerCore.Ad.VASTModel?
            beforeEach { model = nil }
            var input: MidrollDetector.Input!
            beforeEach {
                input = MidrollDetector.Input(
                    midrolls: [
                        .init(cuePoint: 10, url: URL(string: "http://some_url_1")!, id: UUID()),
                        .init(cuePoint: 15, url: URL(string: "http://some_url_2")!, id: UUID()),
                        .init(cuePoint: 20, url: URL(string: "http://some_url_3")!, id: UUID())],
                    prefetchingOffest: 3,
                    currentTime: 0,
                    isPlayMidrollAllowed: true,
                    hasActiveAds: false,
                    isVPAIDAllowed: false,
                    isOpenMeasurementEnabled: true)
            }
            
            beforeEach {
                recorder.record {
                    let dispatcherHook: (PlayerCore.Action) -> Void = recorder.hook("dispatcher") { target, record in
                        switch (target, record) {
                        case (let targetAdRequest as AdRequest, let recordAdRequest as AdRequest):
                            return targetAdRequest.id == recordAdRequest.id
                        case (let targetShowAd as ShowAd, let recordShowAd as ShowAd):
                            guard case .mp4(let targetShowAdCreatives) = targetShowAd.creative,
                                case .mp4(let recordShowAdCreatives) = recordShowAd.creative else { return false }
                            guard let targetShowAdCreative = targetShowAdCreatives.first,
                                let recordShowAdCreative = recordShowAdCreatives.first else { return false }
                            return targetShowAdCreative.url == recordShowAdCreative.url
                        case (let targetSkipAd as SkipAd, let recordSkipAd as SkipAd):
                            return targetSkipAd.id == recordSkipAd.id
                        default: return false
                        }
                    }
                    let requestAdHook: (URL) -> Void = recorder.hook("request ad") { $0 == $1 }
                    func requestAd(url: URL) -> Future<PlayerCore.Ad.VASTModel?> {
                        requestAdHook(url)
                        return Future {
                            model = PlayerCore.Ad.VASTModel(
                                adVerifications: [],
                                mp4MediaFiles: [.init(url: URL(string:"http://test.mp4")!,
                                                      width: 1,
                                                      height: 1,
                                                      scalable: true,
                                                      maintainAspectRatio: true)],
                                vpaidMediaFiles: [],
                                clickthrough: nil,
                                adParameters: nil,
                                pixels: .init(),
                                id: nil)
                            $0(model) }
                    }
                    
                    midrollDetector = MidrollDetector(dispatcher: dispatcherHook,
                                                      requestAd: requestAd)
                }
            }
            
            it("should not fire actions") { recorder.verify {} }
            
            context("actions") {
                context("empty") {
                    it("isPlayMidrollAllowed == false") {
                        input.isPlayMidrollAllowed = false
                        recorder.record { midrollDetector.process(input: input) }
                        recorder.verify {}
                    }
                    
                    it("hasActiveAds == true") {
                        input.hasActiveAds = true
                        recorder.record { midrollDetector.process(input: input) }
                        recorder.verify {}
                    }
                }
                
                context("prefetch") {
                    it("prefetch") {
                        input.currentTime = 8
                        guard case .prefetch(let midroll)? = prefetchAction(input: input,
                                                                            lastPrefetchedMidroll: nil,
                                                                            isPrefetchedModelEmpty: true) else { return XCTFail("Got nil action") }
                        expect(midroll) == input.midrolls[0]
                    }
                    
                    it("forward over 1") {
                        input.currentTime = 12
                        guard case .prefetch(let midroll)? = prefetchAction(input: input,
                                                                            lastPrefetchedMidroll: nil,
                                                                            isPrefetchedModelEmpty: true) else { return XCTFail("Got nil action") }
                        expect(midroll) == input.midrolls[0]
                    }
                    
                    it("forward over 2") {
                        input.currentTime = 16
                        guard case .prefetch(let midroll)? = prefetchAction(input: input,
                                                                            lastPrefetchedMidroll: nil,
                                                                            isPrefetchedModelEmpty: true) else { return XCTFail("Got nil action") }
                        expect(midroll) == input.midrolls[1]
                    }
                }
                
                context("play") {
                    it("first") {
                        input.currentTime = 10
                        guard case .play(let model, let midroll)? = playAction(input: input,
                                                                               lastPrefetchedMidroll: input.midrolls[0],
                                                                               prefetchedModel: nil) else { return XCTFail("Got nil action") }
                        expect(midroll) == input.midrolls[0]
                        expect(model).to(beNil())
                    }
                    
                    it("prefetched first") {
                        input.currentTime = 21
                        guard case .play(let model, let midroll)? = playAction(input: input,
                                                                               lastPrefetchedMidroll: input.midrolls[0],
                                                                               prefetchedModel: nil) else { return XCTFail("Got nil action") }
                        expect(midroll) == input.midrolls[2]
                        expect(model).to(beNil())
                    }
                }
                
                context("nothing") {
                    it("action while requesting ad") {
                        input.currentTime = 15
                        input.hasActiveAds = true
                        recorder.record { midrollDetector.process(input: input) }
                        recorder.verify {}
                    }
                    
                    it("forbidden midroll playing") {
                        input.currentTime = 15
                        input.isPlayMidrollAllowed = false
                        recorder.record { midrollDetector.process(input: input) }
                        recorder.verify {}
                    }
                    
                    it("currentTime is not enough to prefetch") {
                        input.currentTime = 2
                        recorder.record { midrollDetector.process(input: input) }
                        recorder.verify {}
                    }
                }
            }
            
            context("hooks") {
                it("prefetch") {
                    recorder.record {
                        input.currentTime = 8
                        midrollDetector.process(input: input)
                    }
                    
                    recorder.verify {
                        guard let model = model else { return XCTFail("Got nil ad model") }
                        let midroll = input.midrolls[0]
                        midrollDetector.dispatcher(PlayerCore.adRequest(
                            url: midroll.url,
                            id: midroll.id,
                            type: .midroll))
                        _ = midrollDetector.requestAd(midroll.url)
                        expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                        expect(midrollDetector.state.prefetchedModel) == model
                    }
                }
                
                it("play") {
                    recorder.record {
                        input.currentTime = 10
                        midrollDetector.state.lastPrefetchedMidroll = input.midrolls[0]
                        midrollDetector.process(input: input)
                    }
                    
                    recorder.verify {
                        guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                        midrollDetector.dispatcher(PlayerCore.skipAd(id: midrollId))
                    }
                }
                
                context("seek") {
                    it("seek over 1") {
                        
                        recorder.record {
                            input.currentTime = 11
                            midrollDetector.process(input: input)
                            
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            expect(midrollDetector.state.prefetchedModel) == model
                            
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {
                            let midroll = input.midrolls[0]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                            
                            guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                         id: midrollId,
                                                                         isOpenMeasurementEnabled: true))
                        }
                    }
                    
                    it("seek over 1 in prefetch area 2") {
                        recorder.record {
                            input.currentTime = 13
                            midrollDetector.process(input: input)
                            
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            expect(midrollDetector.state.prefetchedModel) == model
                            
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {
                            let midroll = input.midrolls[0]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                            
                            guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                         id: midrollId,
                                                                         isOpenMeasurementEnabled: true))
                        }
                    }
                    
                    it("seek over 2") {
                        recorder.record {
                            input.currentTime = 16
                            midrollDetector.process(input: input)
                            
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            expect(midrollDetector.state.prefetchedModel) == model
                            
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {
                            let midroll = input.midrolls[1]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                            
                            guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                         id: midrollId,
                                                                         isOpenMeasurementEnabled: true))
                        }
                    }
                    
                    it("seek over 2 in prefetch area 3") {
                        recorder.record {
                            input.currentTime = 18
                            // should prefetch 2
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[1]
                            if let model = model {
                                expect(midrollDetector.state.prefetchedModel) == model
                            } else { return XCTFail("Got nil ad model") }
                            // should play 2
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[1]
                            // should prefetch 3
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[2]
                            if let model = model {
                                expect(midrollDetector.state.prefetchedModel) == model
                            } else { return XCTFail("Got nil ad model") }
                            // should play 3
                            input.currentTime = 20
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[2]
                        }
                        
                        recorder.verify {
                            // check prefetch 2
                            var midroll = input.midrolls[1]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            // check play 2
                            if let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id {
                                guard let model = model else { return XCTFail("Got nil ad model") }
                                midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                             id: midrollId,
                                                                             isOpenMeasurementEnabled: true))
                            } else { return XCTFail("Got nil midroll id") }
                            
                            // check prefetch 3
                            midroll = input.midrolls[2]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            // check play 3
                            if let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id {
                                guard let model = model else { return XCTFail("Got nil ad model") }
                                midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                             id: midrollId,
                                                                             isOpenMeasurementEnabled: true))
                            } else { return XCTFail("Got nil midroll id") }
                        }
                    }
                    
                    it("seek over 2 in prefetch area 3 and back to 1") {
                        recorder.record {
                            input.currentTime = 18
                            // should prefetch 2
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[1]
                            if let model = model {
                                expect(midrollDetector.state.prefetchedModel) == model
                            } else { return XCTFail("Got nil ad model") }
                            // should play 2
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[1]
                            // should prefetch 3
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[2]
                            if let model = model {
                                expect(midrollDetector.state.prefetchedModel) == model
                            } else { return XCTFail("Got nil ad model") }
                            // should play 1
                            input.currentTime = 10
                            midrollDetector.process(input: input)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == input.midrolls[0]
                        }
                        
                        recorder.verify {
                            // check prefetch 2
                            var midroll = input.midrolls[1]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            // check play 2
                            if let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id {
                                guard let model = model else { return XCTFail("Got nil ad model") }
                                midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                             id: midrollId,
                                                                             isOpenMeasurementEnabled: true))
                            } else { return XCTFail("Got nil midroll id") }
                            
                            // check prefetch 3
                            midroll = input.midrolls[2]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            // check play 1
                            if let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id {
                                guard let model = model else { return XCTFail("Got nil ad model") }
                                midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                             id: midrollId,
                                                                             isOpenMeasurementEnabled: true))
                            } else { return XCTFail("Got nil midroll id") }
                        }
                    }
                    
                    it("seek over 3") {
                        recorder.record {
                            input.currentTime = 21
                            midrollDetector.process(input: input)
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {
                            let midroll = input.midrolls[2]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                            guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                         id: midrollId,
                                                                         isOpenMeasurementEnabled: true))
                        }
                    }
                    it("seek over 3 and back between 2 and 3") {
                        recorder.record {
                            input.currentTime = 21
                            midrollDetector.process(input: input)
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {
                            let midroll = input.midrolls[2]
                            midrollDetector.dispatcher(PlayerCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
                            _ = midrollDetector.requestAd(midroll.url)
                            expect(midrollDetector.state.lastPrefetchedMidroll) == midroll
                            guard let midrollId = midrollDetector.state.lastPrefetchedMidroll?.id else { return XCTFail("Got nil midroll id") }
                            guard let model = model else { return XCTFail("Got nil ad model") }
                            midrollDetector.dispatcher(PlayerCore.playAd(model: model,
                                                                         id: midrollId,
                                                                         isOpenMeasurementEnabled: true))
                        }
                        
                        recorder.record {
                            input.currentTime = 17
                            midrollDetector.process(input: input)
                            midrollDetector.process(input: input)
                        }
                        
                        recorder.verify {}
                    }
                }
            }
        }
    }
}

