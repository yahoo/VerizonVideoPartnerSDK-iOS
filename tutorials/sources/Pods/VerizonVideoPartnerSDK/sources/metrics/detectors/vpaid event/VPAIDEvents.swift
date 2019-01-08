//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

extension Detectors {
    final class VPAIDEventsDetector {
        
        var trackingEvents: [PlayerCore.VPAIDEvents] = []
        
        func process(events: [PlayerCore.VPAIDEvents]) -> [PlayerCore.VPAIDEvents] {
            guard trackingEvents.count != events.count else { return [] }
            var newEvents: [PlayerCore.VPAIDEvents] = []
            newEvents.append(contentsOf: events.dropFirst(trackingEvents.count))
            trackingEvents = events
            return newEvents
        }
    }
}
