//  Copyright © 2019 Oath Inc. All rights reserved.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreMedia
@testable import VerizonVideoPartnerSDK
import PlayerCore

class PropsMappingTests: XCTestCase {
    typealias Props = Player.Properties
    
    func testCGSize() {
        XCTAssertNotNil((CGSize(width: 100, height: 100) |> json).object)
        XCTAssertEqual((nil as CGSize?) |> json, .null)
    }
    
    func testCMTime() {
        XCTAssertNotNil((CMTime() |> json).object)
        XCTAssertEqual((nil as CMTime?) |> json, .null)
    }
    
    func testJsonForStallRecords() {
        typealias StallRecord = Props.PlayerSession.Playback.StallRecord
        XCTAssertNotNil(([StallRecord(duration: 10, timestamp: 10)] |> json).array)
    }

    func testPlayerProperties() {
        let state = PlayerCore.State(isPlaybackInitiated: false,
                                     hasPrerollAds: false,
                                     midrolls: [],
                                     timeoutBarrier: 0,
                                     maxAdDuration: 0,
                                     isOpenMeasurementEnabled: false)
        let model = PlayerCore.Model(video: .init(url: URL(string: "http://test.com")!,
                                                  renderer: .init(id: "id",
                                                                  version: "version")),
                                     vpaidSettings: .init(document: URL(string: "http://test.com")!),
                                     omSettings: .init(serviceScriptURL: URL(string: "http://test.com")!))
        XCTAssertNotNil((Props(state: state, model: model) |> json).object)
    }
    
    func testUnavailableItem() {
        XCTAssertNotNil((Props.PlaybackItem.unavailable(.init(reason: "reason")) |> json).object)
    }
    
    func testVideoAngles() {
        XCTAssertNotNil(((horizontal:10, vertical: 10) |> json).object)
    }
    
    func testMediaGroup() {
        let sut = Props.PlaybackItem.Video.MediaGroup(options: [.init(id: UUID(),
                                                                      displayName: "displayName",
                                                                      selected: false)])
        XCTAssertNotNil((sut |> json).object)
        XCTAssertEqual((nil as Props.PlaybackItem.Video.MediaGroup?) |> json, .null)
    }
    
    func testNoSubtitles() {
        XCTAssertEqual((nil as Props.PlaybackItem.Video.Subtitles?) |> json, .null)
    }
    
    func testInternalSubtitles() {
        let sut = Props.PlaybackItem.Video.Subtitles.internal(nil)
        XCTAssertNotNil(sut |> json)
    }
    
    func testExternalSubtitles() {
        let sut = Props.PlaybackItem.Video.Subtitles.external(.init(isActive: false,
                                                                    isLoading: false,
                                                                    isLoaded: false,
                                                                    text: "",
                                                                    group: .init(options: [])))
        XCTAssertEqual(sut |> json, .null)
    }
    
    func testThumbnails() {
        let sut = PlayerCore.Model.Video.Thumbnail(items: [.init(width: 100,
                                                                 height: 100,
                                                                 url: URL(string: "http://test.com")!)])
        XCTAssertNotNil((sut |> json).array)
    }
    
    func testAdPixels() {
        XCTAssertNotNil((PlayerCore.AdPixels() |> json).object)
        XCTAssertEqual((nil as PlayerCore.AdPixels?) |> json, .null)
    }
    
    func testAdModel() {
        let sut = AdCreative.MP4(internalID: .init(),
                                 url: URL(string: "http://test.com")!,
                                 clickthrough: nil,
                                 pixels: .init(),
                                 id: nil,
                                 width: 100,
                                 height: 100,
                                 scalable: false,
                                 maintainAspectRatio: false)
        XCTAssertNotNil((sut |> json).object)
        XCTAssertEqual((nil as AdCreative.MP4?) |> json, .null)
    }
    
    func testPlaybackStatus() {
        XCTAssertNotNil((Props.PlaybackItem.Video.Status.ready |> json).object)
        struct TestError: Error { }
        XCTAssertNotNil((Props.PlaybackItem.Video.Status.failed(TestError()) |> json).object)
    }
    
    func testTime() {
        XCTAssertEqual((nil as Props.PlaybackItem.Video.Time?) |> json, .null)
        XCTAssertEqual(Props.PlaybackItem.Video.Time.live(.init(isFinished: false)) |> json, .null)
        let sut = Props.PlaybackItem.Video.Time.static(.init(progress: .init(0),
                                                             currentCMTime: nil,
                                                             current: nil,
                                                             duration: 10,
                                                             hasDuration: false,
                                                             remaining: 0,
                                                             lastPlayedDecile: 0,
                                                             lastPlayedQuartile: 0,
                                                             isFinished: false))
        XCTAssertNotNil((sut |> json).object)
    }
}
