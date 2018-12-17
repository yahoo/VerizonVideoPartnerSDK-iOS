//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK
@testable import PlayerCore

class VRMRequestControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let url = URL(string: "http://test.com")!
    let vrmURL = URL(string: "http://vrm.com")!
    let vastString = "vast String"
    let itemMetaInfo = VRMProvider.Item.MetaInfo(engineType: "engineType",
                                                 ruleId: "ruleId",
                                                 ruleCompanyId: "ruleCompanyId",
                                                 vendor: "vendor",
                                                 name: "name")
    
    var urlItem: VRMProvider.Item { return .url(url, itemMetaInfo) }
    var vastItem: VRMProvider.Item { return .vast(vastString, itemMetaInfo) }
    var itemsResponse: [[VRMProvider.Item]] { return [[urlItem], [vastItem]] }
    
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testItemsMappingTwoGroupsOneItem() {
        let response = [[urlItem], [vastItem]]
        let groups = mapGroups(from: response)
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].items.count, 1)
        XCTAssertEqual(groups[1].items.count, 1)
        XCTAssertTrue(groups[0].items[0] == urlItem)
        XCTAssertTrue(groups[1].items[0] == vastItem)
    }
    
    func testItemsMappingOneGroupTwoItems() {
        let response = [[urlItem, vastItem]]
        let groups = mapGroups(from: response)
        XCTAssertEqual(groups.count, 1)
        XCTAssertEqual(groups[0].items.count, 2)
        XCTAssertTrue(groups[0].items[0] == urlItem)
        XCTAssertTrue(groups[0].items[1] == vastItem)
    }
    
    func testAdResponseDispatch() {
        let groupsMapper: VRMRequestController.GroupsMapper = { inputItems in
            XCTAssertEqual(inputItems, self.itemsResponse)
            return []
        }
        
        let dispatch: (PlayerCore.Action) -> Void = recorder.hook("dispatch ad response") { targetAction, recordedAction -> Bool in
            guard let targetAction = targetAction as? PlayerCore.VRMCore.VRMResponseAction,
                let recordedAction = recordedAction as? PlayerCore.VRMCore.VRMResponseAction else {
                    return false
            }
            return targetAction.slot == recordedAction.slot &&
                targetAction.transactionId == recordedAction.transactionId &&
                targetAction.groups == recordedAction.groups
        }
        
        let sut = VRMRequestController(dispatch: dispatch,
                                       groupsMapper: groupsMapper,
                                       fetchVRMResponse: { url -> Future<VRMProvider.Response?> in
                                        
                                        XCTAssertEqual(url, self.vrmURL)
                                        
                                        return Future(value: VRMProvider.Response(transactionId: "transactionId",
                                                                                  slot: "slot",
                                                                                  cpm: "cpm",
                                                                                  items: self.itemsResponse)) })
        
        
        recorder.record {
            let requestId = UUID()
            sut.process(with: .request(url: vrmURL, id: requestId))
            sut.process(with: .request(url: vrmURL, id: requestId))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.adResponse(transactionId: "transactionId",
                                            slot: "slot",
                                            groups: []))
        }
        
        recorder.record {
            sut.process(with: .request(url: vrmURL, id: UUID()))
            sut.process(with: .request(url: vrmURL, id: UUID()))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.adResponse(transactionId: "transactionId",
                                            slot: "slot",
                                            groups: []))
            
            sut.dispatch(VRMCore.adResponse(transactionId: "transactionId",
                                            slot: "slot",
                                            groups: []))
        }
    }
    
    func testRequestFailedDeispatch() {
        let groupsMapper: VRMRequestController.GroupsMapper = { _ in
            return []
        }
        
        let dispatch: (PlayerCore.Action) -> Void = recorder.hook("dispatch ad response") { targetAction, recordedAction -> Bool in
            guard let targetAction = targetAction as? PlayerCore.VRMCore.VRMResponseFetchFailed,
                let recordedAction = recordedAction as? PlayerCore.VRMCore.VRMResponseFetchFailed else {
                    return false
            }
            return targetAction.requestID == recordedAction.requestID
        }
        
        let sut = VRMRequestController(dispatch: dispatch,
                                       groupsMapper: groupsMapper,
                                       fetchVRMResponse: { url -> Future<VRMProvider.Response?> in
                                        return Future(value: nil)
        })
        
        let requestID = UUID()
        recorder.record {
            sut.process(with: .request(url: vrmURL, id: requestID))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.adResponseFetchFailed(requestID: requestID))
        }
    }
}

extension VRMCore.Item {
    public static func ==(lsv: VRMCore.Item,
                          rsv: VRMProvider.Item) -> Bool {
        switch (lsv, rsv) {
        case let (.url(urlLeft, metaInfoLeft), .url(urlRight, metaInfoRight)):
            return urlLeft == urlRight && metaInfoLeft == metaInfoRight
        case let (.vast(vastLeft, metaInfoLeft), .vast(vastRight, metaInfoRight)):
            return vastLeft == vastRight && metaInfoLeft == metaInfoRight
        default: return false
        }
    }
}

extension VRMCore.Item.MetaInfo {
    public static func ==(lsv: VRMCore.Item.MetaInfo,
                          rsv: VRMProvider.Item.MetaInfo) -> Bool {
        return lsv.engineType == rsv.engineType &&
            lsv.ruleId == rsv.ruleId &&
            lsv.ruleCompanyId == rsv.ruleCompanyId &&
            lsv.vendor == rsv.vendor &&
            lsv.name == rsv.name
    }
}
