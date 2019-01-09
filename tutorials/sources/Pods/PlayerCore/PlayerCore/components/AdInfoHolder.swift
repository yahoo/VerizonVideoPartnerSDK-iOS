//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


import Foundation

public struct AdInfoHolder {
    public let pixels: AdPixels
    public let info: VRMMetaInfo
    public let adID: String?
}

func reduce(state: AdInfoHolder?, action: Action) -> AdInfoHolder? {
    switch action {
    case is AdRequest:
        return nil
    case let item as VRMItem:
        guard case .model(let model) = item else { return state }
        return AdInfoHolder(pixels: model.model.pixels,
                            info: model.info,
                            adID: model.adId)
    default: return state
    }
}

public struct TransactionIDHolder {
    public let transactionID: String?
}

func reduce(state: TransactionIDHolder?, action: Action) -> TransactionIDHolder? {
    switch action {
    case is AdRequest:
        return nil
    case let action as ProcessGroups:
        return TransactionIDHolder(transactionID: action.transactionId)
    default: return state
    }
}
