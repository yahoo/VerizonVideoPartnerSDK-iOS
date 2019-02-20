//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import UIKit
import PlayerCore

final class VRMMidrollProcessorController {
    let dispatch: (PlayerCore.Action) -> Void
    
    private var sessionID = UUID()
    private var lastMidroll: PlayerCore.Ad.Midroll?
    private var prevRoundedTime = 0
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    func process(props: Player.Properties) {
        guard let item = props.playbackItem,
            let currentTime = item.content.time.static?.current else { return }
        
        process(midrolls: item.midrolls,
                currentTime: currentTime,
                hasActiveAds: item.hasActiveAds,
                isPlayMidrollAllowed: item.content.isPaused == false && item.content.isSeeking == false,
                sessionID: props.session.playback.id)
    }
    
    func process(midrolls: [PlayerCore.Ad.Midroll],
                 currentTime: Double,
                 hasActiveAds: Bool,
                 isPlayMidrollAllowed: Bool,
                 sessionID: UUID) {
        guard hasActiveAds == false,
            isPlayMidrollAllowed else { return }
        
        if self.sessionID != sessionID {
            self.sessionID = sessionID
            lastMidroll = nil
            prevRoundedTime = 0
        }
        
        let roundedTime: Int = perform {
            guard currentTime > Double(Int.min) && currentTime < Double(Int.max) else { return 0 }
            return Int(currentTime)
        }
        
        let filteredMidrolls: [PlayerCore.Ad.Midroll] = perform {
            guard roundedTime <= prevRoundedTime else { return midrolls }
            return midrolls.filter {  $0.cuePoint != lastMidroll?.cuePoint }
        }
        
        let midrollsBeforeCurrentTime = filteredMidrolls.filter {
            $0.cuePoint < roundedTime
        }
        
        let midrollsAfterCurrentTime = filteredMidrolls.filter {
            $0.cuePoint >= roundedTime
        }
        
        let candidateBeforeCurrentTime = midrollsBeforeCurrentTime.last{ $0.cuePoint > lastMidroll?.cuePoint ?? 0 }
        let candidateAfterCurrentTime = midrollsAfterCurrentTime.first{ $0.cuePoint == roundedTime }
        
        let midrollToPlay = candidateBeforeCurrentTime ?? candidateAfterCurrentTime
        
        prevRoundedTime = roundedTime
        
        if let midroll = midrollToPlay,
            lastMidroll?.id != midroll.id {
            lastMidroll = midroll
            dispatch(VRMCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
        }
    }
}
