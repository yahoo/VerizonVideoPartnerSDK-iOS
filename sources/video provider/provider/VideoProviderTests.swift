//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


import XCTest
import Nimble
@testable import VerizonVideoPartnerSDK

class VideoProviderTests: XCTestCase {
    func testVideoRequestJSONWithExtra() {
        let json = VideoProvider.Request.makeJSONFrom(
            ids: ["id key": "id value"],
            context: ["context key": "context value"],
            siteSection: "siteSection",
            autoplay: true,
            extra: ["extra key": "extra value"])
        
        let player = json["player"] as? JSON
        let context = player?["context"] as? JSON
        let extra = player?["extra"] as? JSON

        expect(player?.parse("id key")) == "id value"
        expect(context?.parse("context key")) == "context value"
        expect(extra?.parse("extra key")) == "extra value"
        expect(player?.parse("sitesection")) == "siteSection"
        expect(player?.parse("autoplay")) == true
    }
    
    func testVideoRequestJSONWithoutExtra() {
        let json = VideoProvider.Request.makeJSONFrom(
            ids: ["id key": "id value"],
            context: ["context key": "context value"],
            siteSection: "",
            autoplay: false,
            extra: [:])
        
        let player = json["player"] as? JSON
        expect(player).toNot(beNil())
        expect(player?["extra"]).to(beNil())
    }
    
    
    static let renderer360: JSON = [
        "id": "id 360",
        "version": "version 360"
    ]
    
    static let rendererFlat: JSON = [
        "id": "id flat",
        "version": "version flat"
    ]
    
    func testRendererParsing() {
        let parse = VideoProvider.Parse.renderer
        var value: VideoProvider.Response.Video.Descriptor
        
        value = try! parse(VideoProviderTests.renderer360)
        expect(value.id) == "id 360"
        expect(value.version) == "version 360"
        
        value = try! parse(VideoProviderTests.rendererFlat)
        expect(value.id) == "id flat"
        expect(value.version) == "version flat"
        
        expect(try parse(["unknown": "value"])).to(throwError())
    }

    static let podTimePreroll = [ "time" : "preroll" ]
    static let podTimePostroll = [ "time" : "postroll" ]
    static let podTimeMidroll = [ "time" : 50 ]
    static let podTimeWrongType = [ "time" : "50" ]
    static let podTimeUnsupported = [ "time" : [] ]
    
    func testPodTimeParsing() {
        let parse = VideoProvider.Parse.podTime
        
        guard case .preroll = try! parse(VideoProviderTests.podTimePreroll) else {
            return XCTFail()
        }
        guard case .postroll = try! parse(VideoProviderTests.podTimePostroll) else {
            return XCTFail()
        }
        guard case let .seconds(seconds) = try! parse(VideoProviderTests.podTimeMidroll) else {
            return XCTFail()
        }
        expect(seconds) == 50
        expect(try parse(VideoProviderTests.podTimeWrongType)).to(throwError())
        expect(try parse(VideoProviderTests.podTimeUnsupported)).to(throwError())
    }
    
    static let podsize1: JSON = [
        "time" : "preroll",
        "url" : "http://test.com/vrm"
    ]
    
    static let podsize2: JSON = [
        "time": "postroll",
        "url": "http://test.com/"
    ]
    
    func testAdSlotParsing() {
        let parse = VideoProvider.Parse.pod
        var value: VideoProvider.Response.Pod
        
        value = try! parse(VideoProviderTests.podsize1)
        guard case .preroll = value.time else { return XCTFail() }
        expect(value.url.absoluteString) == "http://test.com/vrm"
        
        value = try! parse(VideoProviderTests.podsize2)
        guard case .postroll = value.time else { return XCTFail() }
        expect(value.url.absoluteString) == "http://test.com/"
        
        expect(try parse(["time": VideoProviderTests.podTimePreroll, "size": 0])).to(throwError())
        expect(try parse(["time": VideoProviderTests.podTimePreroll, "size": -5])).to(throwError())
        expect(try parse(["time": "preroll"])).to(throwError())
        expect(try parse(["time": VideoProviderTests.podTimePreroll])).to(throwError())
        expect(try parse(["size": 1])).to(throwError())
    }
    
    static let thumbnail1: JSON = [
        "width": 50 as NSNumber,
        "height": 60 as NSNumber,
        "url": "http://thumb.com/1.jpg"
    ]
    
    func testThumbnailParsing() {
        let parse = VideoProvider.Parse.thumbnail
        var value: VideoProvider.Response.Thumbnail
        
        value = try! parse(VideoProviderTests.thumbnail1)
        expect(value.width) == 50
        expect(value.height) == 60
        expect(value.url.absoluteString) == "http://thumb.com/1.jpg"
        
        let zeroWidth: JSON =  ["width": 0 as NSNumber, "height":60 as NSNumber, "url": "http://thumb.com/1.jpg"]
        expect(try parse(zeroWidth)).to(throwError())
        
        let zeroHeight: JSON = ["width": 50 as NSNumber, "height": 0 as NSNumber, "url": "http://thumb.com/1.jpg"]
        expect(try parse(zeroHeight)).to(throwError())
        
        let emptyURL: JSON = ["width": 50 as NSNumber, "height": 60 as NSNumber, "url": ""]
        expect(try parse(emptyURL)).to(throwError())
    }

    static let trackers: JSON = [
        "view": ["http://view.com", "http://view1.com"],
        "impression": ["http://impression.com"]
    ]
    
    func testBrandedTrackerParser() {
        let parse = VideoProvider.Parse.brandedContentTracker
        var value: VideoProvider.Response.Video.BrandedContent.Tracker?
        
        value = try! parse(VideoProviderTests.trackers)
        expect(value?.view).toNot(beEmpty())
        expect(value?.impression).toNot(beEmpty())
        
        expect(value?.view.first) == URL(string:"http://view.com")
        expect(value?.view.last) == URL(string:"http://view1.com")
        expect(value?.impression.first) == URL(string:"http://impression.com")
        
        expect(value?.click).to(beEmpty())
        expect(value?.quartile1).to(beEmpty())
        expect(value?.quartile2).to(beEmpty())
        expect(value?.quartile3).to(beEmpty())
        expect(value?.quartile4).to(beEmpty())
        
        let wrongUrl: JSON = ["view": [""]]
        expect(try parse(wrongUrl)).to(throwError())
        
        expect(try parse(nil)).to(beNil())
    }
    
    static let brandedContent: JSON = [
        "clickUrl": "http://test.com",
        "advertisementText": "advertisementText",
        "trackers": trackers
    ]
    
    func testBrandedContentParsing() {
        let parse = VideoProvider.Parse.brandedContent
        var value: VideoProvider.Response.Video.BrandedContent?
        
        value = try! parse(VideoProviderTests.brandedContent)
        expect(value?.advertisementText) == "advertisementText"
        expect(value?.clickUrl) == URL(string: "http://test.com")
        expect(value?.tracker).toNot(beNil())
        
        let emptyURL: JSON = ["clickUrl": NSNull(), "advertisementText": "advertisementText"]
        expect(try parse(emptyURL)?.clickUrl).to(beNil())
        expect(try parse(nil)).to(beNil())
    }
    
    static let videoWithInternalSubtitles: JSON = [
        "id": "video1 id",
        "url": "http://video.com/video1",
        "title": "video1 title",
        "thumbnails": [],
        "renderer": VideoProviderTests.rendererFlat,
        "pods": [],
        "isScreenCastingEnabled" : false,
        "isPictureInPictureEnabled" : true
    ]
    
    static let videoWithExternalSubtitles: JSON = [
        "id": "video2 id",
        "url": "http://video.com/video2",
        "title": "video2 title",
        "thumbnails": [VideoProviderTests.thumbnail1],
        "renderer": VideoProviderTests.rendererFlat,
        "pods": [
            VideoProviderTests.podsize1,
            VideoProviderTests.podsize2
        ],
        "isScreenCastingEnabled" : true,
        "isPictureInPictureEnabled" : true,
        "brandedContent": VideoProviderTests.brandedContent
    ]
    
    func testVideoParsing() {
        let parse = VideoProvider.Parse.video
        var value: VideoProvider.Response.Video
        
        let expectedRenderer = try! VideoProvider.Response.Video.Descriptor(
            id: "id flat",
            version: "version flat")
        
        value = try! parse(VideoProviderTests.videoWithInternalSubtitles)
        expect(value.id) == "video1 id"
        expect(value.url.absoluteString) == "http://video.com/video1"
        expect(value.title) == "video1 title"
        
        expect(value.thumbnails.count) == 0
        expect(value.renderer) == expectedRenderer
        expect(value.pods.count) == 0
        
        expect(value.brandedContent).to(beNil())
        
        value = try! parse(VideoProviderTests.videoWithExternalSubtitles)
        expect(value.id) == "video2 id"
        expect(value.url.absoluteString) == "http://video.com/video2"
        expect(value.title) == "video2 title"
        
        expect(value.thumbnails.count) == 1
        expect(value.renderer) == expectedRenderer
        expect(value.pods.count) == 2
        expect(value.isScreenCastingEnabled) == true
        expect(value.isPictureInPictureEnabled) == true
        expect(value.brandedContent).toNot(beNil())
    }
    
    static let videoResponse: JSON = ["video": VideoProviderTests.videoWithInternalSubtitles]
    static let restrictedResponse: JSON = ["restricted": ["reason": "restricted reason"]]
    static let missedResponse: JSON = ["missing": ["reason": "missed reason"]]
    static let invalidResponse: JSON = ["invalid": ["reason": "invalid reason"]]
    static let missingRenderer: JSON = ["missingRenderer": ["id": "com.renderer.id", "version" : "1.0"]]
    
    func testVideoResponseParsing() {
        let parse = VideoProvider.Parse.videoResponse
        var value: VideoProvider.Response.VideoResponse
        
        value = try! parse(VideoProviderTests.videoResponse)
        guard case .video = value else { return XCTFail() }
        
        value = try! parse(VideoProviderTests.restrictedResponse)
        guard case let .restricted(reason1) = value else { return XCTFail() }
        expect(reason1) == "restricted reason"
        
        value = try! parse(VideoProviderTests.missedResponse)
        guard case let .missing(reason2) = value else { return XCTFail() }
        expect(reason2) == "missed reason"

        value = try! parse(VideoProviderTests.invalidResponse)
        guard case let .invalid(reason3) = value else { return XCTFail() }
        expect(reason3) == "invalid reason"
        
        value = try! parse(VideoProviderTests.missingRenderer)
        guard case let .missingRenderer(renderer) = value else { return XCTFail() }
        expect(renderer.id) == "com.renderer.id"
        expect(renderer.version) == "1.0"
        
        expect(try parse(["redirect": [:]])).to(throwError())
    }
    
    static let trackingContext: JSON = [
        "context": [
            "playerVersion": "111",
            "trkUrl": "https://trackingBeacons.com",
            "adUrl": "https://trackingsAds.com",
            "pid": "222",
            "sessionID": "333",
            "uuid": "444",
            "referringURL": "http://referringURL.sdk",
            "vid": [
            "777"
            ],
            "bcid": "555",
            "playerType": "testType",
            "videoPlayType": "testType",
            "sitesection": "testsection",
            "app_id": "666",
            "platformSupport": "testPlatform",
            "vcdn": nil,
            "apid": nil,
            "vcid": nil,
            "mpid": nil,
            "spaceId": "123123"
        ]
    ]
    
    func testNativeTrackingContextParsing() throws {
        let parse = VideoProvider.Parse.tracking
        let value = try parse(VideoProviderTests.trackingContext, .native)
        
        guard case .native(let native) = value else { return XCTFail("Expecting `native` tracking!") }
        XCTAssertEqual(native.playerVersion, "111")
        XCTAssertEqual(native.adURL.absoluteString, "https://trackingsAds.com")
        XCTAssertEqual(native.trkURL.absoluteString, "https://trackingBeacons.com")
        XCTAssertEqual(native.pid, "222")
        XCTAssertEqual(native.bcid, "555")
        XCTAssertEqual(native.appID, "666")
        XCTAssertEqual(native.uuid, "444")
        XCTAssertEqual(native.playerType, "testType")
        XCTAssertEqual(native.videoIds.first, "777")
        XCTAssertEqual(native.sessionId, "333")
        XCTAssertEqual(native.referringURLString, "http://referringURL.sdk")
        XCTAssertEqual(native.platformSupport, "testPlatform")
        XCTAssertNil(native.vcdn)
        XCTAssertNil(native.apid)
        XCTAssertNil(native.vcid)
        XCTAssertNil(native.mpid)
        XCTAssertEqual(native.spaceId, "123123")
    }
    
    func testJavascriptTrackingContextParsing() throws {
        let parse = VideoProvider.Parse.tracking
        let value = try parse(VideoProviderTests.trackingContext, .javascript)
        
        guard case .javascript(let context) = value else { return XCTFail("Expecting `javascript` tracking!") }
        XCTAssertGreaterThan(context.keys.count, 0)
        XCTAssertGreaterThan(context.values.count, 0)
    }
    
    static let features: JSON = [
        "isControlsAnimationEnabled": false,
        "isVPAIDAllowed": true,
        "isOpenMeasurementEnabled": true,
        "isFailoverEnabled": true
    ]
    
    static let adSettings: JSON = [
        "prefetchingOffset" : 7,
        "softTimeout" : 0.5,
        "hardTimeout" : 2.5,
        "startTimeout": 3.5,
        "maxSearchTime" : 9.0,
        "maxShowTime": 90,
        "maxVASTWrapperRedirectCount": 3,
    ]
    
    static let fullResponse: JSON = [
        "videos": [
            VideoProviderTests.videoResponse,
            VideoProviderTests.restrictedResponse,
            VideoProviderTests.missedResponse,
            VideoProviderTests.invalidResponse
        ],
        "adSettings" : VideoProviderTests.adSettings,
        "tracking": VideoProviderTests.trackingContext,
        "autoplay": true,
        "features": VideoProviderTests.features
    ]
    
    static let emptyResponse: JSON = ["videos": []]
    
    func testResponseParsing() {
        let parse = VideoProvider.Parse.response
        var value: VideoProvider.Response
        
        value = try! parse(VideoProviderTests.fullResponse, .native)
        expect(value.videos.count) == 4
        expect(value.features.isControlsAnimationEnabled) == false
        expect(value.features.isVPAIDAllowed) == true
        expect(value.features.isOpenMeasurementEnabled) == true
        expect(value.features.isFailoverEnabled) == true
        expect(value.adSettings.prefetchingOffset) == 7
        expect(value.adSettings.softTimeout) == 0.5
        expect(value.adSettings.hardTimeout) == 2.5
        expect(value.adSettings.startTimeout) == 3.5
        expect(value.adSettings.maxDuration) == 90
        expect(value.adSettings.maxVASTWrapperRedirectCount) == 3
        expect(value.adSettings.maxSearchTime) == 9.0
        
        expect(try parse(VideoProviderTests.emptyResponse, .native)).to(throwError())
    }
    
    func testURLParsing() {
        let parse = VideoProvider.Parse.url
        
        let fullExample = "http://test.com/path?p=q&a=2"
        expect(try parse(fullExample).absoluteString) == fullExample
        
        expect(try parse("test.com/path?p=q&a=2")).to(throwError())
        expect(try parse("path?p=q&a=2")).to(throwError())
        expect(try parse("")).to(throwError())
    }
    
    static let trackingContextFull: JSON = [
        "context": [
            "playerVersion": "111",
            "trkUrl": "https://trackingBeacons.com",
            "adUrl": "https://trackingsAds.com",
            "pid": "222",
            "sessionID": "333",
            "uuid": "444",
            "referringURL": "http://referringURL.sdk",
            "vid": [
                "777"
            ],
            "bcid": "555",
            "playerType": "testType",
            "videoPlayType": "testType",
            "sitesection": "testsection",
            "app_id": "666",
            "platformSupport": "testPlatform",
            "mediaFileHosts": ["com.domain.1", "com.domain.2"],
            "apid": "apid",
            "vcid": [nil, "test"],
            "mpid": [nil, "test"],
            "spaceId" : "123123"
        ]
    ]
    
    func testNativeTrackingContextParsingWithMediaFileHostsAndApid() throws {
        let parse = VideoProvider.Parse.tracking
        let value = try parse(VideoProviderTests.trackingContextFull, .native)
        
        guard case .native(let native) = value else { return XCTFail("Expecting `native` tracking!") }
        XCTAssertEqual(native.playerVersion, "111")
        XCTAssertEqual(native.adURL.absoluteString, "https://trackingsAds.com")
        XCTAssertEqual(native.trkURL.absoluteString, "https://trackingBeacons.com")
        XCTAssertEqual(native.pid, "222")
        XCTAssertEqual(native.bcid, "555")
        XCTAssertEqual(native.appID, "666")
        XCTAssertEqual(native.uuid, "444")
        XCTAssertEqual(native.playerType, "testType")
        XCTAssertEqual(native.videoIds.first, "777")
        XCTAssertEqual(native.sessionId, "333")
        XCTAssertEqual(native.referringURLString, "http://referringURL.sdk")
        XCTAssertEqual(native.platformSupport, "testPlatform")
        XCTAssertEqual(native.vcdn?.count, 2)
        XCTAssertEqual(native.vcdn?[0], "com.domain.1")
        XCTAssertEqual(native.vcdn?[1], "com.domain.2")
        XCTAssertEqual(native.apid, "apid")
        XCTAssertNotNil(native.vcid)
        XCTAssertNotNil(native.mpid)
        XCTAssertNil(native.vcid?[0])
        XCTAssertNil(native.mpid?[0])
        XCTAssertEqual(native.vcid?[1], "test")
        XCTAssertEqual(native.mpid?[1], "test")
        XCTAssertEqual(native.spaceId, "123123")
    }
}
