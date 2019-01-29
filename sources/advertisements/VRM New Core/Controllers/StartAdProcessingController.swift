//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import UIKit
import PlayerCore

final class StartAdProcessingController {
    
    let dispatch: (PlayerCore.Action) -> Void
    let prefetchOffset: Int
    
    private var sessionID = UUID()
    private var isPrerollRequested = false
    private var lastMidroll: PlayerCore.Ad.Midroll?
    
    init(prefetchOffset: Int,
         dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.prefetchOffset = prefetchOffset
        self.dispatch = dispatch
    }
    
    func process(props: Player.Properties) {
        processPreroll(with: props.playbackItem?.model.ad.preroll.first?.url,
                       isPlaybackInitiated: props.isPlaybackInitiated,
                       sessionID: props.session.playback.id)
        
        guard let item = props.playbackItem,
            let currentTime = item.content.time.static?.current else { return }
        
        processMidroll(midrolls: item.midrolls,
                       currentTime: currentTime,
                       hasActiveAds: item.hasActiveAds,
                       isPlayMidrollAllowed: item.content.isPaused == false && item.content.isSeeking == false)
    }
    
    func processPreroll(with url: URL?,
                        isPlaybackInitiated: Bool,
                        sessionID: UUID,
                        requestID: UUID = UUID()) {
        guard let url = url,
            isPlaybackInitiated else { return }
        
        if self.sessionID != sessionID {
            self.sessionID = sessionID
            isPrerollRequested = false
        }
        
        if isPrerollRequested == false {
            isPrerollRequested = true
            dispatch(VRMCore.adRequest(url: url, id: requestID, type: .preroll))
        }
    }
    
    func processMidroll(midrolls: [PlayerCore.Ad.Midroll],
                        currentTime: Double,
                        hasActiveAds: Bool,
                        isPlayMidrollAllowed: Bool) {
        guard hasActiveAds == false,
            isPlayMidrollAllowed else { return }
        
        let roundedTime: Int = perform {
            guard currentTime > Double(Int.min) && currentTime < Double(Int.max) else { return 0 }
            return Int(currentTime)
        }
        
        let midrollsBeforeCurrentTime = midrolls.filter {
            $0.cuePoint < roundedTime && $0.cuePoint > lastMidroll?.cuePoint ?? 0
        }
        
        let midrollsAfterCurrentTime = midrolls.filter {
            $0.cuePoint >= roundedTime
        }
        
        let midrollToPlay = midrollsBeforeCurrentTime.last ??
            midrollsAfterCurrentTime.first{ $0.cuePoint == roundedTime }
        
        if let midroll = midrollToPlay,
            lastMidroll?.id != midroll.id {
            lastMidroll = midroll
            dispatch(VRMCore.adRequest(url: midroll.url, id: midroll.id, type: .midroll))
        }
    }
}

