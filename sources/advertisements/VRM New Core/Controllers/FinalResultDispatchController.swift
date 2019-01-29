//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

final class FinalResultDispatchController {
    let dispatch: (PlayerCore.Action) -> Void
    let isOpenMeasurementEnabled: Bool
    
    private var firedResults = Set<VRMCore.Result>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void,
         isOpenMeasurementEnabled: Bool) {
        self.dispatch = dispatch
        self.isOpenMeasurementEnabled = isOpenMeasurementEnabled
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmFinalResult.result,
                requestID: state.vrmRequestStatus.request?.id)
    }
    
    func process(with finalResult: VRMCore.Result?,
                 requestID: UUID?) {
        guard let finalResult = finalResult,
            let requestID = requestID,
            firedResults.contains(finalResult) == false else {
                return
        }
        firedResults.insert(finalResult)
        dispatch(PlayerCore.playAd(model: finalResult.inlineVAST,
                                   id: requestID,
                                   isOpenMeasurementEnabled: isOpenMeasurementEnabled))
    }
}
