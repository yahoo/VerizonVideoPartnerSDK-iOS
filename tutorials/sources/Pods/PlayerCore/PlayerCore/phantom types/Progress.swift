//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public struct Progress {
    public typealias NativeValue = Double
    
    public let value: NativeValue
    public var lastPlayedQuartile: Int {
        switch value {
        case ..<0.25: return 0
        case ..<0.5: return 1
        case ..<0.75: return 2
        case ..<1: return 3
        case 1...: return 4
        default: fatalError("Unhandled quartile!")
        }
    }
    public var lastPlayedDecile: Int {
        return min(10, Int(value * 10))
    }
    public var isMax: Bool {
        return value == 1
    }
    
    public init(_ value: NativeValue) {
        let value = value.isNaN ? 0 : value
        self.value = min(max(value, 0), 1)
    }
    
    public init(_ value: CGFloat) {
        self.init(NativeValue(value))
    }
    
    public init(_ value: Int) {
        self.init(NativeValue(value))
    }
    
    public func multiply(time: CMTime) -> CMTime {
        return CMTimeMultiplyByFloat64(time, multiplier: value)
    }
}

extension Progress: ExpressibleByIntegerLiteral {
    public typealias IntegerLiteralType = Int
    public init(integerLiteral value: IntegerLiteralType) {
        self.init(NativeValue(value))
    }
}

extension Progress: ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public init(floatLiteral value: FloatLiteralType) {
        self.init(NativeValue(value))
    }
}

extension Progress: Equatable {
    public static func ==(lhs: Progress, rhs: Progress) -> Bool {
        return lhs.value == rhs.value
    }
}
