//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class MP4AdCreativeController {
    
    let dispatch: (PlayerCore.Action) -> Void
    private var processedCreatives = Set<PlayerCore.AdCreative>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void) {
        self.dispatch = dispatch
    }
    
    
    func process(state: State) {
        process(adCreative: state.selectedAdCreative,
                viewport: state.viewport.dimensions,
                id: state.vrmRequestStatus.request?.id)
    }
    
    func process(adCreative: PlayerCore.AdCreative, viewport: CGSize?, id: UUID?) {
        guard case .mp4(let creatives) = adCreative,
            processedCreatives.contains(adCreative) == false,
            let dimensions = viewport,
            let id = id else { return }
        
        processedCreatives.insert(adCreative)
        
        guard creatives.count > 1 else {
            guard let creative = creatives.first else { fatalError("Failed to unwrap existing value") }
            dispatch(PlayerCore.showMP4Ad(creative: creative, id: id))
            return
        }
        
        creatives
            .sorted {
                let firstDiff = abs(dimensions.width * dimensions.height - CGFloat($0.width) * CGFloat($0.height))
                let secondDiff = abs(dimensions.width * dimensions.height - CGFloat($1.width) * CGFloat($1.height))
                return firstDiff < secondDiff }
            .first
            .flatMap { dispatch(PlayerCore.showMP4Ad(creative: $0, id: id)) }
    }
}
