//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class FinalResultDispatchControllerTest: XCTestCase {

    let recorder = Recorder()
    var sut: FinalResultDispatchController!
    
    override func setUp() {
        let comparator = ActionComparator<ShowAd> {
            $0.creative == $1.creative &&
            $0.adVerifications == $1.adVerifications &&
            $0.isOpenMeasurementEnabled == $1.isOpenMeasurementEnabled
        }
        let dispatch = recorder.hook("hook", cmp: comparator.compare)
        sut = FinalResultDispatchController(dispatch: dispatch, isOpenMeasurementEnabled: true)
    }
    
    func testShowAdDispatch() {
        let item = VRMCore.Item(source: .vast(""), metaInfo: .init(engineType: nil,
                                                                   ruleId: nil,
                                                                   ruleCompanyId: nil,
                                                                   vendor: "",
                                                                   name: nil,
                                                                   cpm: nil))
        let inlineVAST = PlayerCore.Ad.VASTModel(adVerifications: [],
                                                 mp4MediaFiles: [.init(url: URL(string:"http://test.mp4")!,
                                                                        width: 1,
                                                                        height: 1,
                                                                        scalable: true,
                                                                        maintainAspectRatio: true)],
                                                 vpaidMediaFiles: [],
                                                 clickthrough: nil,
                                                 adParameters: "",
                                                 pixels: .init(), id: nil)
        let result = VRMCore.Result(item: item, inlineVAST: inlineVAST)
        
        recorder.record {
            let uuid = UUID()
            sut.process(with: nil, requestID: nil)
            sut.process(with: nil, requestID: uuid)
            sut.process(with: result, requestID: uuid)
            sut.process(with: result, requestID: uuid)
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.playAd(model: inlineVAST,
                                           id: .init(),
                                           isOpenMeasurementEnabled: sut.isOpenMeasurementEnabled))
        }
    }
}
