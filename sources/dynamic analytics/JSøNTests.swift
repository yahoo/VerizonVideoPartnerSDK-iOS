//  Copyright © 2019 Oath Inc. All rights reserved.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import CoreGraphics
@testable import VerizonVideoPartnerSDK

class JSøNTests: XCTestCase {

    func testJsonObject() {
        let sut = JSøN.object([
            "number" : .number(NSNumber(10)),
            "bool" : .bool(true),
            "null" : .null,
            "string" : .string("string"),
            "array" : .array([JSøN.string("test")]),
            "object" : .object(["object" : JSøN.string("object")])
            ]
        )
        guard let json = sut.jsonObject as? [String: Any] else { XCTFail("Not `[String: Any]`!"); return }
        XCTAssertEqual(json["number"] as? NSNumber, NSNumber(10))
        XCTAssertEqual(json["bool"] as? Bool, true)
        XCTAssertEqual(json["null"] as? NSNull, NSNull())
        XCTAssertEqual(json["string"] as? String, "string")
        XCTAssertNotNil(json["array"] as? Array<Any>)
        XCTAssertNotNil(json["object"] as? [String: Any])
    }
    
    func testBool() {
        XCTAssertTrue((true |> json).bool ?? false)
        XCTAssertEqual(((nil as Bool?) |> json), .null)
    }
    
    func testString() {
        XCTAssertEqual(("123" |> json).string, "123")
        XCTAssertEqual(((nil as String?) |> json), .null)
    }

    func testUint() {
        XCTAssertEqual((UInt(10) |> json).number, NSNumber(value: UInt(10)))
        XCTAssertEqual(((nil as UInt?) |> json), .null)
    }
    
    func testInt() {
        XCTAssertEqual((Int(10) |> json).number, NSNumber(value: Int(10)))
        XCTAssertEqual(((nil as Int?) |> json), .null)
    }
    
    func testInt64() {
        XCTAssertEqual((Int64(10) |> json).number, NSNumber(value: Int64(10)))
        XCTAssertEqual(((nil as Int64?) |> json), .null)
    }
    
    func testInt32() {
        XCTAssertEqual((Int32(10) |> json).number, NSNumber(value: Int32(10)))
        XCTAssertEqual(((nil as Int32?) |> json), .null)
    }
    
    func testUInt32() {
        XCTAssertEqual((UInt32(10) |> json).number, NSNumber(value: UInt32(10)))
        XCTAssertEqual(((nil as UInt32?) |> json), .null)
    }
    
    func testFloat() {
        XCTAssertEqual((Float(10) |> json).number, NSNumber(value: Float(10)))
        XCTAssertEqual(((nil as Float?) |> json), .null)
    }
    
    func testCGFloat() {
        XCTAssertEqual((CGFloat(10) |> json).number, NSNumber(value: CGFloat(10).native))
        XCTAssertEqual(((nil as CGFloat?) |> json), .null)
    }
    
    func testDouble() {
        XCTAssertEqual((Double(10) |> json).number, NSNumber(value: Double(10)))
        XCTAssertEqual(((nil as Double?) |> json), .null)
    }
    
    func testObject() {
        XCTAssertEqual((["key" : .string("value")] |> json).object, ["key" : .string("value")])
        XCTAssertEqual(((nil as [String : JSøN]?) |> json), .null)
    }
    
    func testArray() {
        XCTAssertEqual(([.string("value")] |> json).array, [.string("value")])
        XCTAssertEqual(((nil as [JSøN]?) |> json), .null)
    }
    
    func testUuid() {
        XCTAssertNotNil((UUID() |> json).string)
    }
    
    func testUrl() {
        XCTAssertNotNil((URL(string: "http://test.com") |> json).string)
    }
}
