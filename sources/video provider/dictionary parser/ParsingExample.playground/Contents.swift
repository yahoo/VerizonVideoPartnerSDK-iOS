//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
@testable import VerizonVideoPartnerSDK

let json = [
    "int" : 1,
    "float" : 0.5,
    "bool" : true,
    "string" : "abc",
    "array" : ["1", "2", "3"],
    "object" : [
        "field_1" : "value1",
        "field_2" : "value2"
    ] as JSON
] as JSON

struct Value {
    let int: Int
    let float: Float
    let bool: Bool
    let string: String
    let array: [String]
    let object: Object; struct Object {
        let field1: String
        let field2: String
    }
}

func doWith<T, U>(value: T, transform: T -> U) -> U {
    return transform(value)
}

let value = Value(
    int: json.parse("int"),
    float: json.parse("float"),
    bool: json.parse("bool"),
    string: json.parse("string"),
    array: json.parse("array"),
    object: doWith(json.parse("object")) { Value.Object(
        field1: $0.parse("field_1"),
        field2: $0.parse("field_2"))
    })

json.parse("string") as String
json.parse("array") as [String]
json.parse("int") as Int
json.parse("bool") as Bool
json.parse("float") as Float

json.parse("object").parse("field_1") as String
json.parse("object").parse("field_2") as S
