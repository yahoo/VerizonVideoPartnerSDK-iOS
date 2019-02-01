//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
import PlayerCore
class VerifyBuldTests: XCTestCase {
    
    func testVerifyBuildMethod() {
        let dispatcher: (PlayerCore.Action) -> () = {_ in}
        var result: PlayerCore.Ad.VASTModel?
        let url = URL(string: "https://example.com")!
        let model = PlayerCore.Ad.VASTModel(
            adVerifications: [],
            mp4MediaFiles: [],
            vpaidMediaFiles: [Ad.VASTModel.VPAIDMediaFile(url: url,
                                                          scalable: false,
                                                          maintainAspectRatio: true)],
            clickthrough: nil,
            adParameters: "",
            pixels: AdPixels(),
            id: "id")
        
        result = select(model: model,
                        dispatcher: dispatcher,
                        info: VRMMetaInfo(engineType: "",
                                          ruleId: "",
                                          ruleCompanyId: "",
                                          vendor: "",
                                          name: "",
                                          cpm: ""),
                        requestDate: Date(),
                        isVPAIDAllowed: true)
        XCTAssertNotNil(result)
        
        result = select(model: model,
                        dispatcher: dispatcher,
                        info: VRMMetaInfo(engineType: "",
                                          ruleId: "",
                                          ruleCompanyId: "",
                                          vendor: "",
                                          name: "",
                                          cpm: ""),
                        requestDate: Date(),
                        isVPAIDAllowed: false)
        XCTAssertNil(result)
    }
    
    
    
}
