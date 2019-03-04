//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class AdStartTimeoutController {
    
    typealias OnFire = () -> ()
    typealias TimerFactory = (@escaping OnFire) -> Cancellable
    
    let timerFactory: TimerFactory
    let dispatcher: (PlayerCore.Action) -> Void
    
    private(set) var timer: Cancellable?
    private var processedRequestIDs = Set<UUID>()
    
    init(dispatcher: @escaping (PlayerCore.Action) -> Void,
         timerFactory: @escaping TimerFactory) {
        self.timerFactory = timerFactory
        self.dispatcher = dispatcher
    }
    
    func process(state: State) {
        process(currentAdState: state.ad.currentAd,
                isStreamPlaying: state.rate.adRate.stream,
                isVPAIDCreative: state.selectedAdCreative.isVPAID)
    }
    
    func process(currentAdState: PlayerCore.Ad.State,
                 isStreamPlaying: Bool,
                 isVPAIDCreative: Bool) {
        switch currentAdState {
        case .play where timer == nil:
            timer = timerFactory { [weak self] in
                let action = isVPAIDCreative ? vpaidAdStartTimeoutReached() : mp4AdStartTimeoutReached()
                self?.dispatcher(action)
            }
            
        case .play where isStreamPlaying:
            timer?.cancel()
            
        case .empty where timer != nil:
            timer?.cancel()
            timer = nil
            
        default: break
        }
    }
}
