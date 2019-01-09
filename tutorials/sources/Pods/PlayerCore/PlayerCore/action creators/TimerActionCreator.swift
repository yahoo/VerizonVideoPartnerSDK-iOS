//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public func timerAction(currentAdState: Ad.State,
                        timerState: TimerSession.State,
                        adStreamRate: Bool,
                        maxAdDuration: Int,
                        currentTime: Date = .init(),
                        dispatcher: (Action) -> Void ){
    switch currentAdState {
    case .play where adStreamRate == true && timerState != .running:
        dispatcher(StartTimer(date: currentTime))
    case .play where adStreamRate == false && timerState == .running:
        dispatcher(PauseTimer(date: currentTime))
    case .empty where timerState != .stopped:
        dispatcher(StopTimer(maxAdDuration: maxAdDuration))
    default: break
    }
}
