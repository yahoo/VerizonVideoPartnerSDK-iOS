//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Foundation

@testable import VerizonVideoPartnerSDK

class VASTParserTests: XCTestCase {
    var bundle: Bundle { return Bundle(for: type(of: self)) }
    
    func getVAST(atPath path: String) -> String {
        guard let path = bundle.path(forResource: path, ofType: "xml") else {
            fatalError("Cannot extract resource")
        }
        
        guard let result = try? String(contentsOfFile: path) else {
            fatalError("Cannot build string from path: \(path)")
        }
        
        return result
    }
    
    func testParseVastWithMixedDataInMediaFile() {
        let vast = getVAST(atPath: "VAST1")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case let .inline(inlineModel) = model else { return XCTFail() }
        guard let url = inlineModel.mp4MediaFiles.first?.url.absoluteString else { return XCTFail() }
        XCTAssertEqual(url,
                       "https://dev.example.com/videos/2018/video_example_1280x720.mp4")
        XCTAssertEqual(inlineModel.id, "4203085")
    }
    
    func testVASTExampleCDATA() {
        let vast = getVAST(atPath: "VASTExampleCDATA")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case let .inline(inlineModel) = model else { return XCTFail() }
        
        XCTAssertEqual(inlineModel.mp4MediaFiles.first?.url.absoluteString,
                       "http://localhost:3000/adasset/1331/229/7969/lo.mp4")
    }
    
    func testParseWrapperVAST() {
        let vast = getVAST(atPath: "VASTWrapper")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST xml") }
        guard case let .wrapper(wrapperModel) = model else { return XCTFail() }
        let expectedUrlString = "http://myTrackingURL/adTagURL"
        XCTAssertEqual(wrapperModel.tagURL.absoluteString.removingPercentEncoding,
                       expectedUrlString)
        XCTAssertFalse(wrapperModel.adVerifications.isEmpty)
    }
    
    func testParseWrapperWithExtensionVAST() {
        let vast = getVAST(atPath: "VASTWrapperWithExtension")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST xml") }
        guard case let .wrapper(wrapperModel) = model else { return XCTFail() }
        XCTAssertFalse(wrapperModel.adVerifications.isEmpty)
    }
    
    func testParseVpaidVAST() {
        let vast = getVAST(atPath: "VASTVpaid")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST VPAID xml") }
        guard case let .inline(vpaidModel) = model else { return XCTFail() }
        let expectedURLString = "http://localhost:3000/vpaid/6/video.js"
        XCTAssertEqual(vpaidModel.vpaidMediaFiles.first?.url.absoluteString, expectedURLString)
    }
    
    func testParseAdVerification() {
        let vast = getVAST(atPath: "VAST1")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case .inline(let inlineModel) = model else { return XCTFail() }
        
        XCTAssertEqual(inlineModel.adVerifications.count, 1)
        guard let adVerification = inlineModel.adVerifications.first else { return XCTFail("Missing AdVerification") }
        
        XCTAssertEqual(adVerification.vendorKey, "TestAppVendor")
        XCTAssertEqual(adVerification.javaScriptResource.absoluteString, "https://verificationcompany1.com/verification_script1.js")
        XCTAssertEqual(adVerification.verificationParameters?.absoluteString, "http://localhost:3000/0/beacons")
        XCTAssertEqual(adVerification.verificationNotExecuted?.absoluteString, "http://localhost:3000/0/beacons/vast/verification-not-executed.gif")
    }
    
    func testParseAdVerificatiosWhereOnenWithoutVendorAndParameters() {
        let vast = getVAST(atPath: "VASTExampleCDATA")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case .inline(let inlineModel) = model else { return XCTFail() }
        
        XCTAssertEqual(inlineModel.adVerifications.count, 2)
    }
    
    func testParseAdVerificationWithoutResource() {
        let vast = getVAST(atPath: "VASTVpaid")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case .inline(let inlineModel) = model else { return XCTFail() }
        
        XCTAssertNil(inlineModel.adVerifications.first)
    }
    
    func testParseAdVerificationInExtension() {
        let vast = getVAST(atPath: "VASTVerificationInExtension")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail() }
        guard case .inline(let inlineModel) = model else { return XCTFail() }
        
        XCTAssertNotNil(inlineModel.adVerifications.first)
    }
    
    func testParsePixelsFromVAST() {
        let vast = getVAST(atPath: "VASTExampleCDATA")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST VPAID xml") }
        guard case let .inline(vpaidModel) = model else { return XCTFail() }
        let url = "http://localhost:3000/6/beacons/vast/"
        XCTAssertEqual(vpaidModel.pixels.impression.first?.absoluteString, url + "impression.gif")
        XCTAssertEqual(vpaidModel.pixels.error.first?.absoluteString, url + "error.gif")
        XCTAssertEqual(vpaidModel.pixels.clickTracking.first?.absoluteString, url + "click.gif")
        XCTAssertEqual(vpaidModel.pixels.firstQuartile.first?.absoluteString, url + "firstQuartile.gif")
        XCTAssertEqual(vpaidModel.pixels.midpoint.first?.absoluteString, url + "midpoint.gif")
        XCTAssertEqual(vpaidModel.pixels.thirdQuartile.first?.absoluteString, url + "thirdQuartile.gif")
        XCTAssertEqual(vpaidModel.pixels.complete.first?.absoluteString, url + "complete.gif")
        XCTAssertEqual(vpaidModel.pixels.pause.first?.absoluteString, url + "pause.gif")
        XCTAssertEqual(vpaidModel.pixels.resume.first?.absoluteString, url + "resume.gif")
        XCTAssertEqual(vpaidModel.pixels.skip.first?.absoluteString, url + "skip.gif")
        XCTAssertEqual(vpaidModel.pixels.mute.first?.absoluteString, url + "mute.gif")
        XCTAssertEqual(vpaidModel.pixels.unmute.first?.absoluteString, url + "unmute.gif")
        XCTAssertEqual(vpaidModel.pixels.acceptInvitation.first?.absoluteString, url + "acceptInvitation.gif")
        XCTAssertEqual(vpaidModel.pixels.close.first?.absoluteString, url + "close.gif")
        XCTAssertEqual(vpaidModel.pixels.collapse.first?.absoluteString, url + "collapse.gif")
    }
    
    func testParseAdSkipInTime() {
        let vast = getVAST(atPath: "VAST1")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST VPAID xml") }
        guard case let .inline(vpaidModel) = model else { return XCTFail() }
        XCTAssertEqual(vpaidModel.skipOffset, .time(3663.123))
    }
    
    func testParseAdSkipInPersentage() {
        let vast = getVAST(atPath: "VASTExampleCDATA")
        guard let model = VASTParser.parseFrom(string: vast) else { return XCTFail("Failed to parse VAST VPAID xml") }
        guard case let .inline(vpaidModel) = model else { return XCTFail() }
        XCTAssertEqual(vpaidModel.skipOffset, .percentage(32))
    }
}
