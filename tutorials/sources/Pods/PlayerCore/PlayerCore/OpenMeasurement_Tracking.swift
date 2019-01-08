//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension OpenMeasurement {
    public struct AdEvents {
        public let impressionOccurred: () -> ()
        public init(impressionOccurred: @escaping () -> ()) {
            self.impressionOccurred = impressionOccurred
        }
    }
    public struct VideoEvents {
        public let loaded: (AdPosition, Bool) -> Void
        public let bufferFinish: () -> Void
        public let bufferStart: () -> Void
        public let start: (CGFloat, CGFloat) -> Void
        public let firstQuartile: () -> Void
        public let midpoint: () -> Void
        public let thirdQuartile: () -> Void
        public let complete: () -> Void
        public let resume: () -> Void
        public let pause: () -> Void
        public let click: () -> Void
        public let volumeChange: (CGFloat) -> Void
        
        public enum AdPosition {
            case preroll, midroll
        }
        public init(loaded: @escaping (AdPosition, Bool) -> Void,
                    bufferFinish: @escaping () -> Void,
                    bufferStart: @escaping () -> Void,
                    start: @escaping (CGFloat, CGFloat) -> Void,
                    firstQuartile: @escaping () -> Void,
                    midpoint: @escaping () -> Void,
                    thirdQuartile: @escaping () -> Void,
                    complete: @escaping () -> Void,
                    resume: @escaping () -> Void,
                    pause: @escaping () -> Void,
                    click: @escaping () -> Void,
                    volumeChange: @escaping (CGFloat) -> Void) {
            self.loaded = loaded
            self.bufferFinish = bufferFinish
            self.bufferStart = bufferStart
            self.start = start
            self.firstQuartile = firstQuartile
            self.midpoint = midpoint
            self.thirdQuartile = thirdQuartile
            self.complete = complete
            self.resume = resume
            self.pause = pause
            self.click = click
            self.volumeChange = volumeChange
        }
        
    }
}

extension OpenMeasurement.AdEvents {
    static let empty = OpenMeasurement.AdEvents(impressionOccurred: {})
}
extension OpenMeasurement.VideoEvents {
    static let empty = OpenMeasurement.VideoEvents(loaded: {_,_  in},
                                                   bufferFinish: {},
                                                   bufferStart: {},
                                                   start: {_,_ in},
                                                   firstQuartile: {},
                                                   midpoint: {},
                                                   thirdQuartile: {},
                                                   complete: {},
                                                   resume: {},
                                                   pause: {},
                                                   click: {},
                                                   volumeChange: {_ in})
}
