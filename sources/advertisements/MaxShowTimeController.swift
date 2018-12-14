//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

public final class MaxShowTimeController {
    
    private(set) var timer: Cancellable?
    private let timerCreator: (TimeInterval)->Cancellable
    private let maxAdDuration: Int
    private let dispatcher: (PlayerCore.Action) -> Void
    
    public init(timerCreator: @escaping (TimeInterval)->Cancellable,
                maxAdDuration: Int,
                dispatcher: @escaping (PlayerCore.Action) -> Void ) {
        self.timerCreator = timerCreator
        self.maxAdDuration = maxAdDuration
        self.dispatcher = dispatcher
    }
    
    public func process(state: PlayerCore.State) {
        process(timerSessionState: state.adMaxShowTime.state,
                allowedDuration: state.adMaxShowTime.allowedDuration)
        timerAction(currentAdState: state.ad.currentAd,
                            timerState: state.adMaxShowTime.state,
                            adStreamRate: state.rate.adRate.stream,
                            maxAdDuration: maxAdDuration,
                            dispatcher: dispatcher)
    }
    
    public func process(timerSessionState: TimerSession.State,
                        allowedDuration: TimeInterval) {
        switch timerSessionState {
        case .running where timer == nil:
            timer = timerCreator(allowedDuration)
            
        case .paused, .stopped:
            timer?.cancel()
            timer = nil
            
        default: break
        }
    }
}
