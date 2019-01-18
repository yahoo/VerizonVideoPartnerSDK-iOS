//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMTimeoutController {
    
    let softTimeoutTimerFactory: () -> Cancellable
    let hardTimeoutTimerFactory: () -> Cancellable
    
    private var softTimeoutTimer: Cancellable?
    private var hardTimeoutTimer: Cancellable?
    
    private var startedGroups = Set<VRMCore.Group.ID>()
    
    init(softTimeoutTimerFactory: @escaping () -> Cancellable,
         hardTimeoutTimerFactory: @escaping () -> Cancellable) {
        self.softTimeoutTimerFactory = softTimeoutTimerFactory
        self.hardTimeoutTimerFactory = hardTimeoutTimerFactory
    }
    
    func process(with state: PlayerCore.State) {
        process(currentGroup: state.vrmCurrentGroup.currentGroup)
    }
    
    func process(currentGroup: VRMCore.Group?) {
        guard let currentGroup = currentGroup else {
            softTimeoutTimer?.cancel()
            hardTimeoutTimer?.cancel()
            return
        }
        
        if startedGroups.contains(currentGroup.id) == false {
            startedGroups.insert(currentGroup.id)
            softTimeoutTimer = softTimeoutTimerFactory()
            hardTimeoutTimer = hardTimeoutTimerFactory()
        }
    }
}
