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
                id: UUID())
    }
    
    func process(adCreative: PlayerCore.AdCreative, viewport: CGSize?, id: UUID) {
        guard let dimensions = viewport else { return }
        guard case .mp4(let creatives) = adCreative else { return }
        guard processedCreatives.contains(adCreative) == false else { return }
        processedCreatives.insert(adCreative)
        
        guard creatives.count > 1 else {
            guard let creative = creatives.first else { fatalError("Failed to unwrap existing value") }
            dispatch(PlayerCore.showMP4Ad(creative: creative, id: id))
            return
        }
        var diff: CGFloat = CGFloat.greatestFiniteMagnitude;
        var result: PlayerCore.AdCreative.MP4? = nil
        for creative in creatives {
            let newDiff = abs(dimensions.width * dimensions.height - CGFloat(creative.width) * CGFloat(creative.height));
            if newDiff < diff {
                diff = newDiff;
                result = creative;
            }
        }
        guard let adCreative = result else { return }
        dispatch(PlayerCore.showMP4Ad(creative: adCreative, id: id))
    }
}
