//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class MaxAdSearchTimeController {
    
    let timerFactory: (UUID) -> Cancellable
    
    private var timer: Cancellable?
    private var processedRequestIDs = Set<UUID>()
    
    init(timerFactory: @escaping (UUID) -> Cancellable) {
        self.timerFactory = timerFactory
    }
    
    func process(with state: PlayerCore.State) {
        process(requestID: state.vrmRequestStatus.request?.id,
                isStreamStarted: state.rate.adRate.stream || state.rate.contentRate.stream)
    }

    func process(requestID: UUID?,
                 isStreamStarted: Bool) {
        guard let requestID = requestID else {
            return
        }
        
        if isStreamStarted {
            timer?.cancel()
            timer = nil
        } else if processedRequestIDs.contains(requestID) == false {
            processedRequestIDs.insert(requestID)
            timer = timerFactory(requestID)
        }
    }
}
