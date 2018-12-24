//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

func vastMapper(vastModel: VASTModel) -> VRMCore.VASTModel {
    switch vastModel {
    case .wrapper(let wrapper):
        let vrmCoreWrapper = VRMCore.VASTModel.WrapperModel(tagURL: wrapper.tagURL,
                                                            adVerifications: wrapper.adVerifications,
                                                            pixels: wrapper.pixels)
        return VRMCore.VASTModel.wrapper(vrmCoreWrapper)
    case .inline(let model):
        return VRMCore.VASTModel.inline(model)
    }
}

final class ParseVRMItemController {
    
    let dispatch: (PlayerCore.Action) -> Void
    let parseXML: (String) -> Future<VASTModel?>
    let vastMapper: (VASTModel) -> VRMCore.VASTModel
    
    private var startedItems = Set<PlayerCore.VRMParseItemQueue.Candidate>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void,
         vastMapper: @escaping (VASTModel) -> VRMCore.VASTModel,
         parseXML: @escaping (String) -> Future<VASTModel?>) {
        self.dispatch = dispatch
        self.vastMapper = vastMapper
        self.parseXML = parseXML
    }
    
    func process(with state: PlayerCore.State) {
        process(with: state.vrmParseItemsQueue.candidates)
    }
    
    func process(with parseCandidates: Set<PlayerCore.VRMParseItemQueue.Candidate>) {
        parseCandidates
            .subtracting(startedItems)
            .forEach { candidate in
                self.startedItems.insert(candidate)
                self.parseXML(candidate.vastXML)
                    .onComplete { vastModel in
                        guard let vastModel = vastModel else {
                            self.dispatch(VRMCore.failedItemParse(originalItem: candidate.parentItem,
                                                                  parseCandidate: candidate))
                            return
                        }
                        
                        self.dispatch(VRMCore.completeItemParsing(originalItem: candidate.parentItem,
                                                                  vastModel: self.vastMapper(vastModel)))
                }
        }
    }
}
