//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension Detectors {
    final class Heartbeat {
        struct Result {
            let dimensions: CGSize
            let totalStallTime: Int
        }
        
        let interval = 20
        var triggered = false

        func process(stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord],
                     playbackDuration: TimeInterval,
                     isLiveVideo: Bool,
                     dimensions: CGSize?) -> Result? {
            guard let dimensions = dimensions else { return nil }
            guard isLiveVideo else { return nil }
            let playbackDuration = Int(playbackDuration)
            
            guard playbackDuration > 0, (playbackDuration % interval) == 0 else {
                triggered = false
                return nil
            }
            guard !triggered else { return nil }
            triggered = true
            
            return Result(dimensions: dimensions,
                          totalStallTime: totalStallDuration(from: stallRecords,
                                                             playbackDuration: playbackDuration,
                                                             interval: interval))
        }
    }
}

func totalStallDuration(from stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord],
                        playbackDuration: Int,
                        interval: Int) -> Int {
    guard interval > 0 else { return 0 }
    let position = playbackDuration > interval ? playbackDuration / interval : 0
    let start = Double(position * interval)
    let end = Double((position + 1) * interval)
    
    return totalStallDuration(from: stallRecords, start: start, end: end)
}

func totalStallDuration(from stallRecords: [Player.Properties.PlayerSession.Playback.StallRecord],
                        start: Double,
                        end: Double) -> Int {
    
    let records = stallRecords.filter { (start ... end) ~= $0.timestamp }
    return records.map({ $0.duration }).reduce(0, +)
}
