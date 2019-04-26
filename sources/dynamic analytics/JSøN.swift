//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import CoreMedia
import PlayerCore

indirect enum JSøN: Hashable {
    case null
    case bool(Bool)
    case string(String)
    case number(NSNumber)
    case array([JSøN])
    case object([String: JSøN])
}

extension JSøN {
    var jsonObject: Any {
        switch self {
        case .bool(let bool): return bool
        case .number(let number): return number
        case .null: return NSNull()
        case .string(let string): return string
        case .array(let array): return array.map { $0.jsonObject }
        case .object(let object):
            var mapped: [String: Any] = [:]
            object.forEach { key, value in
                mapped[key] = value.jsonObject
            }
            
            return mapped
        }
    }
}

func json(for bool: Bool?) -> JSøN {
    guard let bool = bool else { return .null }
    return JSøN.bool(bool)
}

func json(for string: String?) -> JSøN {
    guard let string = string else { return .null }
    return JSøN.string(string)
}

func json(for uint: UInt?) -> JSøN {
    guard let number = uint as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int64?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: Int32?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for int: UInt32?) -> JSøN {
    guard let number = int as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for float: Float?) -> JSøN {
    guard let number = float as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for float: CGFloat?) -> JSøN {
    guard let number = float as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for double: Double?) -> JSøN {
    guard let number = double as NSNumber? else { return .null }
    return JSøN.number(number)
}

func json(for object: [String: JSøN]?) -> JSøN {
    guard let object = object else { return .null }
    return JSøN.object(object)
}

func json(for array: [JSøN]?) -> JSøN {
    guard let array = array else { return .null }
    return JSøN.array(array)
}

func json(for uuid: UUID?) -> JSøN {
    return json(for: uuid?.uuidString)
}

func json(for url: URL?) -> JSøN {
    return json(for: url?.absoluteString)
}

func json(for urls: [URL]) -> JSøN {
    return urls.map(json) |> json
}
