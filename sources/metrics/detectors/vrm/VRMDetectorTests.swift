//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK
@testable import PlayerCore

class VRMDetectorTests: XCTestCase {
    let id = UUID()
    var detector: Detectors.VRMDetector!
    
    func metaInfo(with vendor: String) -> VRMMetaInfo {
        return VRMMetaInfo(engineType: nil,
                           ruleId: nil,
                           ruleCompanyId: nil,
                           vendor: vendor,
                           name: nil)
    }
    
    func finishResult(transactionID: String?, slot: String) -> AdVRMManager.VRMRequest.State {
        return .finish(.init(transactionID: transactionID,
                             slot: slot,
                             startItems: [],
                             timeoutItems: [],
                             otherErrorItems: [],
                             completeItem: nil))
    }
    
    override func setUp() {
        super.setUp()
        
        detector = Detectors.VRMDetector(vrmRequestID: id)
    }

    func testEmptyDetection() {
        let result = detector.process(
            state: .init(timeoutBarrier: 3500,
                         requestsFired: 0,
                         request: .init(id: UUID(),
                                        timeout: .beforeSoft,
                                        state: .ready)))
        XCTAssertEqual(result.count, 0)
    }
    
    func testVRMRequests() {
        let id1 = UUID()
        var result = detector.process(state: .init(timeoutBarrier: 3500,
                                                   requestsFired: 0,
                                                   request: .init(id: id1,
                                                                  timeout: .beforeSoft,
                                                                  state: .ready)))
        XCTAssertEqual(result.count, 0)
        
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id1,
                                                              timeout: .beforeSoft,
                                                              state: .progress)))
        XCTAssertEqual(result.count, 0)
        
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id1,
                                                              timeout: .beforeSoft,
                                                              state: finishResult(transactionID: "txid",
                                                                                  slot: "slot"))))
        XCTAssertEqual(result.count, 1)

        if case .completeRequest(let request) = result[0] {
            XCTAssertEqual(request.transactionID, "txid")
            XCTAssertEqual(request.slot, "slot")
        } else {
            XCTFail("Unexpected result! \(result)")
        }
        
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: UUID(),
                                                              timeout: .beforeSoft,
                                                              state: finishResult(transactionID: "txid2",
                                                                                  slot: "slot2"))))
        XCTAssertEqual(result.count, 1)
        if case .completeRequest(let request) = result[0] {
            XCTAssertEqual(request.transactionID, "txid2")
            XCTAssertEqual(request.slot, "slot2")
        } else {
            XCTFail("Unexpected result! \(result)")
        }
    }
    
    let date1 = Date()
    let date2 = Date()
    
    func testStartItems() {
        let startItem1 = AdVRMManager.StartItem(
            info: metaInfo(with: "vendor1"),
            itemID: UUID(),
            url: URL(string: "https://test1.com")!,
            requestDate: date1)
        
        let startItem2 = AdVRMManager.StartItem(
            info: metaInfo(with: "vendor2"),
            itemID: UUID(),
            url: URL(string: "https://test2.com")!,
            requestDate: date2)
        
        var sut = AdVRMManager.VRMRequest.State.FinishResult(transactionID: "transactionID",
                                                             slot: "slot",
                                                             startItems: [],
                                                             timeoutItems: [],
                                                             otherErrorItems: [],
                                                             completeItem: nil)
        sut.startItems.insert(startItem1)
        
        var result = detector.process(state: .init(timeoutBarrier: 3500,
                                                   requestsFired: 0,
                                                   request: .init(id: id,
                                                                  timeout: .afterSoft,
                                                                  state: .finish(sut))))
        XCTAssertEqual(result.count, 1)
        if case .startItem(let start) = result[0] {
            XCTAssertEqual(start.info.vendor, "vendor1")
            XCTAssertEqual(start.url.absoluteString, "https://test1.com")
            XCTAssertEqual(start.requestDate, date1)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
        
        sut.startItems.insert(startItem1)
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        XCTAssertEqual(result.count, 0)

        sut.startItems.insert(startItem1)
        sut.startItems.insert(startItem2)
        
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        
        XCTAssertEqual(result.count, 1)
        if case .startItem(let start) = result[0] {
            XCTAssertEqual(start.info.vendor, "vendor2")
            XCTAssertEqual(start.url.absoluteString, "https://test2.com")
            XCTAssertEqual(start.requestDate, date2)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
    }
    
    func testCompleteItems() {
        let completeItem1 = AdVRMManager.CompleteItem(adId: "adId",
                                                      itemID: UUID(),
                                                      info: metaInfo(with: "vendor1"),
                                                      transactionID: "txid",
                                                      responseTime: 1,
                                                      timeout: .beforeSoft,
                                                      requestTimeoutBarrier: 500)

        var sut = AdVRMManager.VRMRequest.State.FinishResult(transactionID: "transactionID",
                                                             slot: "slot",
                                                             startItems: [],
                                                             timeoutItems: [],
                                                             otherErrorItems: [],
                                                             completeItem: nil)
        sut.completeItem = completeItem1
        var result = detector.process(state: .init(timeoutBarrier: 3500,
                                                   requestsFired: 0,
                                                   request: .init(id: id,
                                                                  timeout: .afterSoft,
                                                                  state: .finish(sut))))
        XCTAssertEqual(result.count, 1)
        if case .completeItem(let complete) = result[0] {
            XCTAssertEqual(complete.info.vendor, "vendor1")
            XCTAssertEqual(complete.responseTime, 1)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
    }
    
    func testTimeoutItems() {
        let timeoutItem1 = AdVRMManager.TimeoutItem(info: metaInfo(with: "vendor1"),
                                                    itemID: UUID(),
                                                    transactionID: "txid",
                                                    responseTime: 1,
                                                    timeout: .beforeSoft,
                                                    requestTimeoutBarrier: 500)
        
        let timeoutItem2 = AdVRMManager.TimeoutItem(info: metaInfo(with: "vendor2"),
                                                    itemID: UUID(),
                                                    transactionID: "txid",
                                                    responseTime: 2,
                                                    timeout: .beforeSoft,
                                                    requestTimeoutBarrier: 500)
        
        var sut = AdVRMManager.VRMRequest.State.FinishResult(transactionID: "transactionID",
                                                             slot: "slot",
                                                             startItems: [],
                                                             timeoutItems: [],
                                                             otherErrorItems: [],
                                                             completeItem: nil)
        sut.timeoutItems.insert(timeoutItem1)
        var result = detector.process(state: .init(timeoutBarrier: 3500,
                                                   requestsFired: 0,
                                                   request: .init(id: id,
                                                                  timeout: .afterSoft,
                                                                  state: .finish(sut))))
        XCTAssertEqual(result.count, 1)
        if case .timeoutItem(let timeout) = result[0] {
            XCTAssertEqual(timeout.info.vendor, "vendor1")
            XCTAssertEqual(timeout.responseTime, 1)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
        
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        sut.timeoutItems.insert(timeoutItem1)
        XCTAssertEqual(result.count, 0)
        
        sut.timeoutItems.insert(timeoutItem1)
        sut.timeoutItems.insert(timeoutItem2)
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        
        XCTAssertEqual(result.count, 1)
        if case .timeoutItem(let timeout) = result[0] {
            XCTAssertEqual(timeout.info.vendor, "vendor2")
            XCTAssertEqual(timeout.responseTime, 2)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
    }
    
    func testOtherErrorItems() {
        let otherErrorItem1 = AdVRMManager.OtherErrorItem(info: metaInfo(with: "vendor1"),
                                                          itemID: UUID(),
                                                          transactionID: "txid",
                                                          responseTime: 1,
                                                          timeout: .beforeSoft,
                                                          error: nil)
        
        let otherErrorItem2 = AdVRMManager.OtherErrorItem(info: metaInfo(with: "vendor2"),
                                                          itemID: UUID(),
                                                          transactionID: "txid",
                                                          responseTime: 2,
                                                          timeout: .beforeSoft,
                                                          error: nil)
        
        var sut = AdVRMManager.VRMRequest.State.FinishResult(transactionID: "transactionID",
                                                             slot: "slot",
                                                             startItems: [],
                                                             timeoutItems: [],
                                                             otherErrorItems: [],
                                                             completeItem: nil)
        sut.otherErrorItems.insert(otherErrorItem1)
        
        var result = detector.process(state: .init(timeoutBarrier: 3500,
                                                   requestsFired: 0,
                                                   request: .init(id: id,
                                                                  timeout: .afterSoft,
                                                                  state: .finish(sut))))
        XCTAssertEqual(result.count, 1)
        if case .otherErrorItem(let other) = result[0] {
            XCTAssertEqual(other.info.vendor, "vendor1")
            XCTAssertEqual(other.responseTime, 1)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
        
        sut.otherErrorItems.insert(otherErrorItem1)
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        
        XCTAssertEqual(result.count, 0)
        
        sut.otherErrorItems.insert(otherErrorItem1)
        sut.otherErrorItems.insert(otherErrorItem2)
        result = detector.process(state: .init(timeoutBarrier: 3500,
                                               requestsFired: 0,
                                               request: .init(id: id,
                                                              timeout: .afterSoft,
                                                              state: .finish(sut))))
        
        XCTAssertEqual(result.count, 1)
        if case .otherErrorItem(let other) = result[0] {
            XCTAssertEqual(other.info.vendor, "vendor2")
            XCTAssertEqual(other.responseTime, 2)
        } else {
            XCTFail("Unexpected result! \(result)")
        }
    }
}
