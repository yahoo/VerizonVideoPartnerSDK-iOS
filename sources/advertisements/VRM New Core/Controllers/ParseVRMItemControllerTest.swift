//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class ParseVRMItemControllerTest: XCTestCase {
    
    let recorder = Recorder()
    let completeParsingComparator = ActionComparator<VRMCore.CompleteItemParsing> {
        $0.vastModel == $1.vastModel && $0.originalItem == $1.originalItem
    }
    let failedParseCompare = ActionComparator<VRMCore.ParsingError> {
        $0.originalItem == $1.originalItem && $0.parseCandidate == $1.parseCandidate
    }
    var sut: ParseVRMItemController!
    
    let vastXML = "VAST String"
    var vastItem: VRMCore.Item!
    var parseCandidate: VRMParseItemQueue.Candidate!
    
    
    override func setUp() {
        super.setUp()
        let metaInfo = VRMCore.Item.MetaInfo(engineType: "engineType",
                                             ruleId: "ruleId",
                                             ruleCompanyId: "ruleCompanyId",
                                             vendor: "vendor",
                                             name: "name",
                                             cpm: "cpm")
        
        vastItem = VRMCore.Item(source: .vast(vastXML), metaInfo: metaInfo)
        parseCandidate = VRMParseItemQueue.Candidate(parentItem: vastItem,
                                                     id: VRMCore.ID(),
                                                     vastXML: vastXML)
    }
    
    override func tearDown() {
        recorder.verify {}
        recorder.clean()
        super.tearDown()
    }
    
    func testSuccessfulParse() {
        let result = PlayerCore.Ad.VASTModel(adVerifications: [],
                                             mediaFiles: [],
                                             clickthrough: nil,
                                             adParameters: nil,
                                             pixels: AdPixels(),
                                             id: nil)
        let dispatch = recorder.hook("testSuccessfulParse", cmp: completeParsingComparator.compare)
        let vastMapper: (VASTModel) -> VRMCore.VASTModel = { oldVast in
            guard case let .inline(vast) = oldVast else {
                fatalError()
            }
            return VRMCore.VASTModel.inline(vast)
        }
        sut = ParseVRMItemController(dispatch: dispatch,
                                     vastMapper: vastMapper,
                                     parseXML: { vastXML -> Future<VASTModel?> in
                                        return Future(value: .inline(result))
        })
        
        recorder.record {
            sut.process(with: Set(arrayLiteral: parseCandidate))
            sut.process(with: Set(arrayLiteral: parseCandidate))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.completeItemParsing(originalItem: vastItem, vastModel: .inline(result)))
        }
    }
    
    func testErrorFetch() {
        let dispatch = recorder.hook("testErrorFetch", cmp: failedParseCompare.compare)
        let vastMapper: (VASTModel) -> VRMCore.VASTModel = { _ in
            fatalError()
        }
        sut = ParseVRMItemController(dispatch: dispatch,
                                     vastMapper: vastMapper,
                                     parseXML: { _ in
                                        return Future(value: nil)
        })
        
        recorder.record {
            sut.process(with: Set(arrayLiteral: parseCandidate))
            sut.process(with: Set(arrayLiteral: parseCandidate))
        }
        
        recorder.verify {
            sut.dispatch(VRMCore.failedItemParse(originalItem: vastItem, parseCandidate: parseCandidate))
        }
    }
}
