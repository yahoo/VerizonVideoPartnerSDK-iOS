//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class FetchVRMItemController {
    
    let dispatch: (PlayerCore.Action) -> Void
    let fetchUrl: (URL) -> Future<Result<String>>
    
    private var startedItems = Set<PlayerCore.VRMFetchItemQueue.Candidate>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void,
         fetchUrl: @escaping (URL) -> Future<Result<String>>) {
        self.dispatch = dispatch
        self.fetchUrl = fetchUrl
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmFetchItemsQueue.candidates)
    }
    
    func process(with fetchCandidates: Set<PlayerCore.VRMFetchItemQueue.Candidate>) {
        fetchCandidates
            .subtracting(startedItems)
            .forEach { fetchCandidate in
                self.startedItems.insert(fetchCandidate)
                self.fetchUrl(fetchCandidate.url)
                    .onSuccess { vastXML in
                        self.dispatch(VRMCore.startItemParsing(originalItem: fetchCandidate.parentItem,
                                                               vastXML: vastXML))
                    }.onError { error in
                        self.dispatch(VRMCore.failedItemFetch(originalItem: fetchCandidate.parentItem))
                }
        }
    }
}
