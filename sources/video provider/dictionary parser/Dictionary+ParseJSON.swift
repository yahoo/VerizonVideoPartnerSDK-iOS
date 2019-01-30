//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation


protocol Parsable {
    static func parse(from object: Any) throws -> Self
}

public typealias JSON = [String: Any]

enum ParseError<T>: Swift.Error {
    case cannotConvert(value: Any, toType: T.Type)
}

extension Parsable {
    static func parse(from object: Any) throws -> Self {
        guard let result = object as? Self else {
            throw ParseError.cannotConvert(value: object, toType: Self.self)
        }
        
        return result
    }
}

extension Parsable where Self == Double {
    static func parse(from object: Any) throws -> Double {
        if let doubleResult = object as? Double {
            return doubleResult
        } else if let intResult = object as? Int {
            return Double(intResult)
        } else {
            throw ParseError.cannotConvert(value: object, toType: Self.self)
        }
    }
}

extension String: Parsable {}
extension Int: Parsable {}
extension Int64: Parsable {}
extension Int32: Parsable {}
extension UInt32: Parsable {}
extension UInt: Parsable {}
extension Bool: Parsable {}
extension Float: Parsable {}
extension Double: Parsable {}
extension Dictionary: Parsable {}

extension Array: Parsable {}

extension Array where Element: Parsable {
    static func parse(from object: Any) throws -> Array {
        guard let array = object as? [Any] else {
            throw ParseError.cannotConvert(value: object, toType: [Any].self)
        }
        
        return try array.map(Element.parse(from:))
    }
}

enum JSONError<Key>: Swift.Error {
    case missedKey(Key)
    case cannotParse(key: Key, error: Error)
}

extension Dictionary {
    func parse <T: Parsable> (_ key: Key) throws -> T {
        guard let value = self[key] else {
            throw JSONError.missedKey(key)
        }
        
        do {
            return try T.parse(from: value)
        } catch let parseError {
            throw JSONError.cannotParse(key: key, error: parseError)
        }
    }
    
    func parse <T: Parsable> (_ key: Key) -> T? {
        guard let object = self[key] else { return nil }
        return try? T.parse(from: object)
    }
}
