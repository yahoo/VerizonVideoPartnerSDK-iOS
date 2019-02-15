//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

extension Detectors {
    final class VRMRequestDetector {
        struct Result {
            let transactionId: String?
        }
        
        enum ResponseStatus {
            case noResponse
            case response(transactionID: String?)
            
            init(response: VRMResponse?) {
                switch response {
                case .none:
                    self = .noResponse
                case .some(let value):
                    self = .response(transactionID: value.transactionId)
                }
            }
        }
        
        private var trackedRequests = Set<UUID>()
        
        func process(with state: PlayerCore.State) -> Result? {
            return process(with: state.vrmRequestStatus.request?.id,
                           vrmResponseStatus: ResponseStatus(response: state.vrmResponse))
        }
        
        func process(with requestId: UUID?,
                     vrmResponseStatus: ResponseStatus) -> Result? {
            guard let requestId = requestId,
                case let .response(transactionId) = vrmResponseStatus,
                trackedRequests.contains(requestId) == false else { return nil }
            
            trackedRequests.insert(requestId)
            return Result(transactionId: transactionId)
        }
    }
}
