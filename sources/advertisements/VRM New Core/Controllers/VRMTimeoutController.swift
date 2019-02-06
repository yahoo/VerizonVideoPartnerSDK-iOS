//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMTimeoutController {
    
    typealias OnFire = (()->())
    typealias TimerFactory = (@escaping OnFire) -> Cancellable
    
    private struct TimerHolder {
        let soft: Cancellable
        let hard: Cancellable
        
        func cancel() {
            soft.cancel()
            hard.cancel()
        }
    }
    
    let dispatch: (PlayerCore.Action) -> Void
    let softTimeoutTimerFactory: TimerFactory
    let hardTimeoutTimerFactory: TimerFactory
    
    private var timeoutTimerHolder: TimerHolder?
    
    private var startedGroups = Set<VRMCore.Group.ID>()
    private var currentFetchingQueue = [VRMCore.Item]()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void,
         softTimeoutTimerFactory: @escaping TimerFactory,
         hardTimeoutTimerFactory: @escaping TimerFactory) {
        self.dispatch = dispatch
        self.softTimeoutTimerFactory = softTimeoutTimerFactory
        self.hardTimeoutTimerFactory = hardTimeoutTimerFactory
    }
    
    func process(with state: PlayerCore.State) {
        process(currentGroup: state.vrmCurrentGroup.currentGroup,
                fetchingQueue: state.vrmFetchItemsQueue.candidates.map{$0.parentItem})
    }
    
    func process(currentGroup: VRMCore.Group?,
                 fetchingQueue: [VRMCore.Item]) {
        guard let currentGroup = currentGroup else {
            timeoutTimerHolder?.cancel()
            currentFetchingQueue = []
            return
        }
        currentFetchingQueue = fetchingQueue
        if startedGroups.contains(currentGroup.id) == false {
            startedGroups.insert(currentGroup.id)
            
            let softTimeoutTimer = softTimeoutTimerFactory({
                self.dispatch(PlayerCore.VRMCore.softTimeoutReached())
            })
            let hardTimeoutTimer = hardTimeoutTimerFactory({
                self.dispatch(PlayerCore.VRMCore.hardTimeoutReached(items: self.currentFetchingQueue))
            })
            
            timeoutTimerHolder = TimerHolder(soft: softTimeoutTimer, hard: hardTimeoutTimer)
        }
    }
}
