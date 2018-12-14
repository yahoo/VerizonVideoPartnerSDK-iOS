//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble
import PlayerCore
@testable import OathVideoPartnerSDK

class PlayerDestructionTests: XCTestCase {
    
    func testPlayerProperDestructionAfterFireStateUpdate() {
        let flat = PlayerCore.Descriptor(id: "com.onemobilesdk.videorenderer.flat", version: "1.0" )
        let model = PlayerCore.Model(
            video: .init(url: URL(string: "http://some_url")!, renderer: flat),
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)
        _ = sut.addObserver { props in
            expect(props.isSessionCompleted) == true
            expect(props.playbackItem?.content.isStreamPlaying) == true
        }
        sut.update(playback: true)
    }
}
