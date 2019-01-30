//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import PlayerCore
@testable import VerizonVideoPartnerSDK

class ObserverTests: XCTestCase {
    
    let testUrl = URL(string: "http://test.com")!
    var token: Player.PropsObserverDispose?
    var sut: Player!
    var currentExpectation: XCTestExpectation!
    let flat = PlayerCore.Descriptor(id: "com.onemobilesdk.videorenderer.flat", version: "1.0" )
    
    override func setUp() {
        sut = Player(model: .init(video: .init(url: testUrl,
                                               renderer: flat),
                                  autoplay: false,
                                  controlsAnimationSupported: false,
                                  isVPAIDAllowed: false,
                                  adSettings: .init(prefetchingOffset: 7,
                                                    softTimeout: 2.5,
                                                    hardTimeout: 3.5,
                                                    startTimeout: 4,
                                                    maxSearchTime: 9,
                                                    maxDuration: 90,
                                                    maxVASTWrapperRedirectCount: 3),
                                  vpaidSettings: .init(document: testUrl),
                                  omSettings: .init(serviceScriptURL: testUrl)))
        currentExpectation = expectation(description: "props update")
    }
    
    func testInitialStateCall() {
        token = sut.addObserver { _ in
            self.currentExpectation.fulfill()
            self.currentExpectation = nil
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }
    
    func testStateUpdateCalls() {
        token = sut.addObserver { _ in
            self.currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        currentExpectation = self.expectation(description: "props update")
        sut.update(playback: true)
        wait(for: [currentExpectation], timeout: 0.1)
        
        currentExpectation = self.expectation(description: "props update")
        sut.update(playback: false)
        sut.update(playback: true)
        wait(for: [currentExpectation], timeout: 0.1)
    }
    
    func testStateUpdateCallsWithEveryUpdate() {
        token = sut.addObserver(mode: .everyUpdate) { _ in
            self.currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        currentExpectation = self.expectation(description: "props update")
        sut.update(playback: true)
        wait(for: [currentExpectation], timeout: 0.2)
        
        currentExpectation = self.expectation(description: "props update")
        currentExpectation.expectedFulfillmentCount = 3
        sut.update(playback: false)
        sut.update(playback: true)
        sut.update(playback: false)
        wait(for: [currentExpectation], timeout: 0.1)
    }
    func testWithUnsubscribe() {
        token = sut.addObserver { _ in
            self.currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        currentExpectation = self.expectation(description: "props update")
        sut.update(playback: false)
        token?()
        currentExpectation.isInverted = true
        wait(for: [currentExpectation], timeout: 0.1)
    }
    func testWithUnsubscribeEveryUpdate() {
        token = sut.addObserver(mode: .everyUpdate) { _ in
            self.currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        currentExpectation = self.expectation(description: "props update")
        sut.update(playback: true)
        token?()
        wait(for: [currentExpectation], timeout: 0.1)
    }
}
