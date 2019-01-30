//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Nimble
@testable import VerizonVideoPartnerSDK

class DictionaryParseJSONTests: XCTestCase {
    var json: JSON!
    
    override func setUp() {
        super.setUp()

        let data = Utils.data(for: type(of: self), with: "test", of: "json")
        // swiftlint:disable force_cast
        // swiftlint:disable force_try
        let arrayJson = try! JSONSerialization.jsonObject(with: data!, options: []) as! [JSON]
        // swiftlint:enable force_try
        // swiftlint:enable force_cast
        json = arrayJson[0]
    }
    
    override func tearDown() {
        json = nil
        
        super.tearDown()
    }
    
    func testStringValue () {
        XCTAssertEqual(try? json.parse("string") as String, "abc")
        XCTAssertEqual(json.parse("string") as String?, "abc")
    }
    
    func testOptionalStringValue () {
        XCTAssertNil(json.parse("missed") as String?)
    }
    
    func testArray () {
        let array = try? json.parse("array") as [String]
        
        XCTAssertEqual(array?[0], "1")
        XCTAssertEqual(array?[1], "2")
        XCTAssertEqual(array?[2], "3")
    }
    
    func testOptionalArray() {
        let array = json.parse("optional_array") as [String]?
        
        XCTAssertNil(array)
    }
    
    struct Object {
        let field1: String
        let field2: String
        let field3: String?
    }
    
    func testObject () {
        do {
            let objectJSON = try json.parse("object") as JSON
            let object = Object(
                field1: try objectJSON.parse("field_1"),
                field2: try objectJSON.parse("field_2"),
                field3: objectJSON.parse("field_3"))
            
            XCTAssertEqual(object.field1, "value1")
            XCTAssertEqual(object.field2, "value2")
            XCTAssertEqual(object.field3, nil)
        } catch { XCTFail() }
    }
    
    func testParseIntValueAsDoubleShouldBeAllowed() {
        let intValue = 1
        let json = ["value": intValue]
        
        let doubleValue: Double? = try? json.parse("value")
        expect(doubleValue) == 1.0
    }
    
    func testParseIntValueAsIntShouldBeAllowed() {
        let intValue = 1
        let json = ["value": intValue]
        
        let parsedInt: Int? = try? json.parse("value")
        expect(parsedInt) == 1
    }
    
    func testParseDoubleAsIntShouldBeRejected() {
        let doubleValue = 1.5
        let json = ["value": doubleValue]
        
        expect(try json.parse("value") as Int).to(throwError())
    }
    
    func testParseDoubleAsDoubleShouldBeAllowed() {
        let doubleValue = 1.5
        let json = ["value": doubleValue]
        
        let parsedInt: Double? = try? json.parse("value")
        expect(parsedInt) == 1.5
    }
}
