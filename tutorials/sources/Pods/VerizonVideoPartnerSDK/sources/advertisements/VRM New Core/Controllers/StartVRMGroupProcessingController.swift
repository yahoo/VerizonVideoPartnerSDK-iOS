//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class StartVRMGroupProcessingController {
    
    let dispatch: (PlayerCore.Action) -> ()
    
    init(dispatch: @escaping (PlayerCore.Action) -> ()) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmCurrentGroup.currentGroup,
                groupsQueue: state.vrmGroupsQueue.groupsQueue)
    }
    
    func process(with currentGroup: VRMCore.Group?,
                 groupsQueue: [VRMCore.Group]) {
        guard currentGroup == nil,
            let nextGroup = groupsQueue.first else { return }
        
        dispatch(VRMCore.startGroupProcessing(group: nextGroup))
    }
}
