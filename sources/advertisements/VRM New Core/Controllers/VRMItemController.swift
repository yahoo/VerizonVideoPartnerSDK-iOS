//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class VRMItemController {
    
    let dispatch: (PlayerCore.Action) -> Void
    
    private var startedItems = Set<VRMCore.Item>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void ) {
        self.dispatch = dispatch
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmScheduledItems.items)
    }
    
    func process(with scheduledItems: Set<VRMCore.Item>) {
        scheduledItems
            .subtracting(startedItems)
            .forEach { item in
            switch (item.source) {
            case let .url(url):
                startedItems.insert(item)
                dispatch(VRMCore.startItemFetch(originalItem: item, url: url))
            case let .vast(vastXML):
                startedItems.insert(item)
                dispatch(VRMCore.startItemParsing(originalItem: item, vastXML: vastXML))
            }
        }
    }
}
