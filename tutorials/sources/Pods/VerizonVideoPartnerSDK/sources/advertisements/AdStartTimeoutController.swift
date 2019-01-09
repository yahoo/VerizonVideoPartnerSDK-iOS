//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class AdStartTimeoutController {
    
    let timerCreator: () -> Cancellable
    private(set) var timer: Cancellable?
    
    init(timerCreator: @escaping () -> Cancellable) {
        self.timerCreator = timerCreator
    }
    
    func process(state: State) {
        process(currentAdState: state.ad.currentAd,
                isStreamPlaying: state.rate.adRate.stream)
    }
    
    func process(currentAdState: PlayerCore.Ad.State,
                 isStreamPlaying: Bool) {
        switch currentAdState {
        case .play where timer == nil:
            timer = timerCreator()
            
        case .play where isStreamPlaying:
            timer?.cancel()
            
        case .empty where timer != nil:
            timer?.cancel()
            timer = nil
            
        default: break
        }
    }
}
