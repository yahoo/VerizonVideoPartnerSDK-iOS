//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class StartVRMGroupProcessingController {
    
    let dispatch: (PlayerCore.Action) -> ()
    private var trackedRequests = Set<UUID>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> ()) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmCurrentGroup.currentGroup,
                groupsQueue: state.vrmGroupsQueue.groupsQueue,
                isMaxAdSearchReached: state.vrmMaxAdSearchTimeout.isReached,
                vrmRequest: state.vrmRequestStatus.request,
                hasReceivedVRMResponse: state.vrmResponse != nil)
    }
    
    func process(with currentGroup: VRMCore.Group?,
                 groupsQueue: [VRMCore.Group],
                 isMaxAdSearchReached: Bool,
                 vrmRequest: VRMRequestStatus.Request?,
                 hasReceivedVRMResponse: Bool) {
        guard currentGroup == nil,
            hasReceivedVRMResponse,
            isMaxAdSearchReached == false else { return }
        
        if let nextGroup = groupsQueue.first {
            dispatch(VRMCore.startGroupProcessing(group: nextGroup))
        } else if let request = vrmRequest,
            trackedRequests.contains(request.id) == false {
            trackedRequests.insert(request.id)
            dispatch(VRMCore.noGroupsToProcess(id: request.id))
        }
    }
}
