//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VPAIDAdCreativeController {
    let dispatch: (PlayerCore.Action) -> Void
    private var processedCreatives = Set<PlayerCore.AdCreative>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    
    func process(state: State) {
        process(adCreative: state.selectedAdCreative, id: state.vrmRequestStatus.request?.id)
    }
    
    func process(adCreative: PlayerCore.AdCreative, id: UUID?) {
        guard case .vpaid(let creatives) = adCreative,
            processedCreatives.contains(adCreative) == false,
            let creative = creatives.first,
            let id = id else { return }
        
        processedCreatives.insert(adCreative)
        dispatch(PlayerCore.showVPAIDAd(creative: creative, id: id))
    }
}
