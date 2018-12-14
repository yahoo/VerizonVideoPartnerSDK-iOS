//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
import PlayerCore
@testable import OathVideoPartnerSDK

class VideoLoadingDetectorIntegrationTests: XCTestCase {
    var detector: Detectors.VideoLoading!
    var token: Player.PropsObserverDispose?
    let flat = PlayerCore.Descriptor(id: "com.onemobilesdk.videorenderer.flat", version: "1.0" )
    override func setUp() {
        super.setUp()
        detector = Detectors.VideoLoading()
    }
    
    override func tearDown() {
        detector = nil
        super.tearDown()
    }
    
    func testInitialLoad() {
        var result = detector.render(isLoaded: true, sessionID: UUID(), isPlaying: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.render(isLoaded: true, sessionID: UUID(), isPlaying: true)
        XCTAssertEqual(result, .beginLoading)
    }
    
    func testStopLoad() {
        let id = UUID()
        var result = detector.render(isLoaded: true, sessionID: id, isPlaying: false)
        XCTAssertEqual(result, .nothing)
        
        result = detector.render(isLoaded: true, sessionID: id, isPlaying: true)
        XCTAssertEqual(result, .beginLoading)
        
        
        result = detector.render(isLoaded: true, sessionID: id, isPlaying: true)
        XCTAssertEqual(result, .endLoading)
    }
    
    func testNothingLoad() {
        let result = detector.render(isLoaded: false, sessionID: UUID(), isPlaying: false)
        XCTAssertEqual(result, .nothing)
    }
    
    func testNextLoad() {
        let id1 = UUID()
        let id2 = UUID()
        var result = detector.render(isLoaded: true, sessionID: id1, isPlaying: true)
        XCTAssertEqual(result, .beginLoading)
        result = detector.render(isLoaded: true, sessionID: id2, isPlaying: true)
        XCTAssertEqual(result, .beginLoading)
    }
    
    func testStartAndFinishLoading() {
        let model = PlayerCore.Model(
            video: .init(url: URL(string: "http://some_url")!,
                         isAirPlayEnabled: false,
                         isPictureInPictureModeSupported: false, renderer: flat),
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)
        
        var currentExpectation = expectation(description: "props update 1")
        
        var result: Detectors.VideoLoading.Result!
        self.token = sut.addObserver {
            result = self.detector?.renderContent(props: $0)
            currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .beginLoading)
        
        sut.update(duration: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update 2")
        wait(for: [currentExpectation], timeout: 0.1)
        
        sut.update(playback: true)
        currentExpectation = expectation(description: "props update 3")
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .nothing)

        token?()
    }
    
    func testLoadingOnPlaylist() {
        let model = PlayerCore.Model(
            videos: [
                PlayerCore.Model.VideoModel(url: URL(string: "http://some_url1")!, renderer: flat),
                PlayerCore.Model.VideoModel(url: URL(string: "http://some_url2")!, renderer: flat)],
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)

        var currentExpectation = expectation(description: "props update")
    
        var result: Detectors.VideoLoading.Result!
            self.token = sut.addObserver {
                result = self.detector?.renderContent(props: $0)
                currentExpectation.fulfill()
            }
            wait(for: [currentExpectation], timeout: 0.1)
        
    
        XCTAssertEqual(result, .beginLoading)
        
        sut.update(duration: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        sut.update(playback: true)
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .nothing)
        
        sut.nextVideo()
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)

        XCTAssertEqual(result, .beginLoading)
        token?()
    }
    

    func testInteruptedLoadingOnPlaylist() {
        let model = PlayerCore.Model(
            videos: [
                PlayerCore.Model.VideoModel(url: URL(string: "http://some_url1")!, renderer: flat),
                PlayerCore.Model.VideoModel(url: URL(string: "http://some_url2")!, renderer: flat)],
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)

        var currentExpectation = expectation(description: "props update")
        var result: Detectors.VideoLoading.Result!
        token = sut.addObserver {
            result = self.detector?.renderContent(props: $0)
            currentExpectation.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)

        XCTAssertEqual(result, .beginLoading)
        
        sut.nextVideo()
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .beginLoading)
        
        token?()
    }
    
    func testFullVideoPlay() {
        let model = PlayerCore.Model(
            video: .init(url: URL(string: "http://some_url")!,
                         renderer: flat),
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)
        
        var currentExpectation = expectation(description: "props update")
        var result: [Detectors.VideoLoading.Result] = []
        token = sut.addObserver {
            if let value = self.detector?.renderContent(props: $0) { result.append(value) }
            currentExpectation.fulfill()
        }
        
        wait(for: [currentExpectation], timeout: 0.1)
        
        sut.update(duration: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        /// not clear, leaving as is, expect to be .beginLoading here
        XCTAssertEqual(result[0], .beginLoading)
        
        sut.update(currentTime: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        sut.update(currentTime: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        XCTAssertEqual(result.last, .nothing)
        
        token?()
    }
    
    func testAdIsNotLoadedNoEventsFired() {
        let model = PlayerCore.Model(
            video: .init(url: URL(string: "http://some_url")!, renderer: flat),
            autoplay: false,
            vpaidSettings: .init(document: URL(string: "http://some")!),
            omSettings: .init(serviceScriptURL: URL(string: "http://some")!))
        let sut = Player(model: model)
        
        var currentExpectation: XCTestExpectation! = expectation(description: "props update")
        var result: Detectors.VideoLoading.Result!
        
        token = sut.addObserver {
            result = self.detector?.renderAd(props: $0)
            currentExpectation?.fulfill()
        }
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .nothing)
        
        sut.update(duration: CMTime(seconds: 10.0, preferredTimescale: 600))
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        sut.update(playback: true)
        currentExpectation = expectation(description: "props update")
        wait(for: [currentExpectation], timeout: 0.1)
        
        XCTAssertEqual(result, .nothing)
        token?()
    }
}
