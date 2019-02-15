//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import PlayerCore

extension VASTParser {
    
    static func getOffset(from string: String) -> PlayerCore.Ad.VASTModel.VASTOffset {
        guard string.isEmpty == false else { return .none }
        if string.contains("%") {
            if let value = Int(string.replacingOccurrences(of: "%", with: "")) {
                return .percentage(value)
            }
        } else if string.contains(":") {
            if let value = TimeOffset(from: string)?.seconds {
                return .time(value)
            }
        }
        return .none
    }
    
    private struct TimeOffset {
        private enum Time {
            case hours([String])
            case minutes([String])
            case seconds([String])
            
            private var maxValue: Int {
                switch self {
                case .hours: return 99
                case .minutes, .seconds: return 59
                }
            }
            private var multiplier: Int {
                switch self {
                case .hours: return 3600
                case .minutes: return 60
                case .seconds: return 1
                }
            }
            private var index: Int {
                switch self {
                case .hours: return 0
                case .minutes: return 1
                case .seconds: return 2
                }
            }
            private var stringTime: String {
                switch self {
                case .hours(let value): return value[self.index]
                case .minutes(let value): return value[self.index]
                case .seconds(let value): return value[self.index]
                }
            }
            
            var resultInSeconds: Int? {
                guard let roundedSeconds = Double(self.stringTime)?.rounded() else { return nil }
                let result = Int(roundedSeconds)
                guard result <= maxValue else { return nil }
                return result * multiplier
            }
            
        }
        
        let seconds: Int
        
        init?(from time: String) {
            let components = time.components(separatedBy: ":")
            guard components.count == 3,
                let hours = Time.hours(components).resultInSeconds,
                let minutes = Time.minutes(components).resultInSeconds,
                let seconds = Time.seconds(components).resultInSeconds else { return nil }
            self.seconds = hours + minutes + seconds
        }
    }
    
}
