//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
@testable import OathVideoPartnerSDK

class ConfigurationParserTests: XCTestCase {
    static func fixtureUrl(with name: String) -> URL {
        let bundle = Bundle(for: ConfigurationParserTests.self)
        let path = bundle.path(forResource: name, ofType: "json")!
        return URL(fileURLWithPath: path)
    }
    
    static func fetchJson(from url: URL) throws -> Any {
        let data = try Data(contentsOf: url)
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
    
    static func createJson(with name: String) throws -> Any {
        return try fetchJson(from: fixtureUrl(with: name))
    }
    
    func testNoVpaid() throws {
        let json = try ConfigurationParserTests.createJson(with: "NoVpaidUrlFixture")
        XCTAssertThrowsError(try parse(any: json) as OVPSDK.Configuration)
    }
    
    func testVpaidParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "NativeTrackingFixture")
        let config = try parse(any: json) as OVPSDK.Configuration
        XCTAssertEqual(config.vpaid.document.absoluteString, "https://document.html")
    }
    func testNoOpenMeasurement() throws {
        let json = try ConfigurationParserTests.createJson(with: "NoOMScriptFixture")
        XCTAssertThrowsError(try parse(any: json) as OVPSDK.Configuration)
    }
    
    func testOpenMeasurementParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "NativeTrackingFixture")
        let config = try parse(any: json) as OVPSDK.Configuration
        XCTAssertEqual(config.openMeasurement.script.absoluteString, "https://script.url")
    }
    
    func testNoTrackingParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "NoTrackingFixture")
        XCTAssertThrowsError(try parse(any: json) as OVPSDK.Configuration)
    }
    
    func testJavascriptTrackingParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "JavascriptTrackingFixture")
        let config = try parse(any: json) as OVPSDK.Configuration
        XCTAssertEqual(config.userAgent, "USER AGENT")
        XCTAssertEqual(config.video.url.absoluteString, "http://localhost:3000/videoservice/single_video_without_ad_javascript_implementation/")
        XCTAssertEqual(config.telemetry?.url.absoluteString, "https://telemetry.url")
        
        guard case .javascript(let javascript) = config.tracking else { return XCTFail("Not a javascript tracking") }
        XCTAssertEqual(javascript.source.absoluteString
            , "http://localhost:3000/javascript/tracking.js")
        XCTAssertEqual(javascript.telemetry.url.absoluteString, "https://telemetry.url")
    }
    
    func testNativeTrackingParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "NativeTrackingFixture")
        let config = try parse(any: json) as OVPSDK.Configuration
        XCTAssertEqual(config.userAgent, "555")
        XCTAssertEqual(config.video.url.absoluteString, "https://video.com")
        XCTAssertEqual(config.telemetry?.url.absoluteString, "https://telemetry.url")
        
        guard case .native = config.tracking else {
            return XCTFail("Not a native tracking")
        }
    }
    
    func testUnrecognizedTrackingTypeParsing() throws {
        let json = try ConfigurationParserTests.createJson(with: "UnrecognizedTrackingFixture")
        XCTAssertThrowsError(try parse(any: json) as OVPSDK.Configuration)
    }
}
