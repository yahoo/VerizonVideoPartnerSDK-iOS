//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import PlayerCore
@testable import OathVideoPartnerSDK

class AdURLProviderTests: XCTestCase {
    
    func testExample() {
        
        class AsyncContext<Params, Result> {
            init() {}
            var params: [Params] = []
            var callbacks: [((Result) -> Void)] = []
            
            func future(params: Params) -> Future<Result> {
                self.params.append(params)
                return Future { work in
                    self.callbacks.append(work)
                }
            }
            
            func function(params: Params, callback: @escaping (Result) -> Void) {
                self.params.append(params)
                self.callbacks.append(callback)
            }
        }
        
        let groupsContext = AsyncContext<URL, VRMProvider.Response?>()
        let itemContext = AsyncContext<VRMProvider.Item, PlayerCore.Ad.VASTModel?>()
        let softTimeoutContext = AsyncContext<TimeInterval, Void>()
        let hardTimeoutContext = AsyncContext<TimeInterval, Void>()
        
        var provider = AdURLProvider(
            groupsFetch: groupsContext.future,
            processItem: itemContext.future,
            softTimeoutAction: softTimeoutContext.function,
            hardTimeoutAction: hardTimeoutContext.function,
            softTimeoutValue: 0.5,
            hardTimeoutValue: 2.5
        )
        
        provider.customUnimplementedHandler = { _ in
            XCTFail("Unimplemented event occurs.")
        }
        
        let url = URL(string: "http://test.com")!
        
        let completionExpectation = expectation(description: "complete request")
        
        provider.requestAd(for: url).onComplete { result in
            completionExpectation.fulfill()
        }
        
        provider.queue.sync {}
        
        guard groupsContext.params.count == 1 else {
            return XCTFail("Missed group request")
        }
        
        XCTAssertEqual(groupsContext.params[0], url)
        
        let metaInfo = VRMProvider.Item.MetaInfo(
            engineType: nil,
            ruleId: nil,
            ruleCompanyId: nil,
            vendor: "vendor",
            name: "name",
            cpm: nil)
        
        let item = VRMProvider.Item.url(url, metaInfo)
        
        let groups = [
            [ item ],
            [ item ]
        ]
        let response = VRMProvider.Response(transactionId: nil,
                                            slot: "slot",
                                            cpm: "cpm",
                                            items:groups)
        
        groupsContext.callbacks[0](response)
        provider.queue.sync {}
        
        XCTAssertEqual(softTimeoutContext.callbacks.count, 1)
        XCTAssertEqual(hardTimeoutContext.callbacks.count, 1)
        
        guard itemContext.callbacks.count == 1 else {
            return XCTFail("Missed first item processing request")
        }
        
        itemContext.callbacks[0](nil)
        provider.queue.sync {}
        
        guard itemContext.callbacks.count == 2 else {
            return XCTFail("Missed second item processing request")
        }
        
        XCTAssertEqual(itemContext.params.count, 2)
        
        itemContext.callbacks[1](nil)
        hardTimeoutContext.callbacks[0](())
        
        provider.queue.sync {}
        
        self.waitForExpectations(timeout: 0.0, handler: nil)
    }
}
