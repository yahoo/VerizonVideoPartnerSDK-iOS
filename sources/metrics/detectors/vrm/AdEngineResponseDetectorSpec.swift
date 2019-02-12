//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Quick
import Nimble
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class AdEngineResponseDetectorSpec: QuickSpec {
    
    override func spec() {
        let startAt = Date(timeIntervalSince1970: 0)
        let finishAt = Date(timeIntervalSince1970: 2)
        let timeout = 2.5
        var metaInfo: VRMCore.Item.MetaInfo!
        var item: VRMCore.Item!
        var detector: Detectors.AdEngineResponseDetector!
        var range: VRMItemResponseTime.TimeRange!
        
        var result: [Detectors.AdEngineResponseDetector.Result]!
        
        beforeEach {
            detector = Detectors.AdEngineResponseDetector()
            
            metaInfo = VRMCore.Item.MetaInfo(engineType: "engineType",
                                             ruleId: "ruleId",
                                             ruleCompanyId: "ruleCompanyId",
                                             vendor: "vendor",
                                             name: "name",
                                             cpm: "cpm")
            item = VRMCore.Item(id: .init(),
                                source: .vast(""),
                                metaInfo: metaInfo)
            
            range = VRMItemResponseTime.TimeRange(startAt: startAt, finishAt: finishAt)
            result = []
        }
        
        it("Double detecting same item") {
            result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.count) == 1
                
            result = detector.process(timeoutBarrier: timeout,
                                      completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.count) == 0
        }
        
        context("On item finish processing") {
            it("in complete") {
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.count) == 1
            }
            
            it("in timeout") {
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [],
                                          timeoutedTimes: [item],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.count) == 1
            }
            
            it("in other errors") {
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [],
                                          timeoutedTimes: [],
                                          otherErrors: [item],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.count) == 1
            }
        }
        
        context("Fill type") {
            it("should be beforeSoft in case of none timeout"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.first?.fillType) == .beforeSoft
            }
            
            it("should be afterSoft in case of soft timeout"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .soft)
                expect(result.first?.fillType) == .afterSoft
            }
            
            it("should be afterHard in case of hard timeout"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .hard)
                expect(result.first?.fillType) == .afterHard
            }
        }
        
        context("Response status") {
            it("should be yes in case of completed item"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [item],
                                          timeoutedTimes: [],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .none)
                expect(result.first?.responseStatus) == .yes
                expect(result.first?.timeout).to(beNil())
            }
            
            it("should be timeout in case of timeout item"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [],
                                          timeoutedTimes: [item],
                                          otherErrors: [],
                                          responseTime: [item: range],
                                          timeoutStatus: .hard)
                expect(result.first?.responseStatus) == .timeout
                expect(result.first?.timeout) == 2500
            }
            
            it("should be no in case of errored item"){
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [],
                                          timeoutedTimes: [],
                                          otherErrors: [item],
                                          responseTime: [item: range],
                                          timeoutStatus: .hard)
                expect(result.first?.responseStatus) == .no
                expect(result.first?.timeout).to(beNil())
            }
        }
        
        context("Response time") {
            it("should be diff between startAt and finishAt in milliseconds") {
                result = detector.process(timeoutBarrier: timeout,
                                          completedItems: [],
                                          timeoutedTimes: [],
                                          otherErrors: [item],
                                          responseTime: [item: range],
                                          timeoutStatus: .hard)
                expect(result.first?.responseTime) == 2000
            }
        }
    }
}
