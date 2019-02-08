//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import VerizonVideoPartnerSDK
@testable import PlayerCore

class VPAIDAdCreativeControllerTest: XCTestCase {
    
    let recorder = Recorder()
    var sut: VPAIDAdCreativeController!
    var id: UUID!
    
    override func setUp() {
        let comparator = ActionComparator<ShowVPAIDAd> {
            $0.creative == $1.creative && $0.id == $1.id
        }
        let dispatch = recorder.hook("hook", cmp: comparator.compare)
        sut = VPAIDAdCreativeController(dispatch: dispatch)
        id = UUID()
    }
    
    func testSingleMP4Creative() {
        let selected = getVPAIDCreative()
        recorder.record {
            sut.process(adCreative: .vpaid([selected]),id: id)
            sut.process(adCreative: .vpaid([selected]),id: UUID())
            
        }
        
        recorder.verify {
            sut.dispatch(PlayerCore.ShowVPAIDAd(creative: selected, id: id))
        }
    }
    
    func testIncorectCreative() {
        recorder.record {
            sut.process(adCreative: .none, id: id)
            sut.process(adCreative: .mp4([getMP4Creative(width: 10, height: 10)]), id: id)
        }
        
        recorder.verify {}
    }
    
}
