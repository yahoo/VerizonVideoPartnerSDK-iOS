//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum AdType {
    case preroll, midroll
}

public func adRequest(url: URL, id: UUID, type: AdType) -> Action {
    return AdRequest(url: url, id: id, type: type)
}

public func adProcessGroup(transactionId: String?, slot: String) -> Action {
    return ProcessGroups(transactionId: transactionId, slot: slot)
}

public func adVRMItemStart(info: VRMMetaInfo, url: URL, requestDate: Date) -> Action {
    return VRMItem.start(.init(info: info,
                               url: url,
                               requestDate: requestDate))
}

public func adVRMItemResponse(adId: String?,
                              info: VRMMetaInfo,
                              model: Ad.VASTModel,
                              requestDate: Date,
                              responseDate: Date) -> Action {
    return VRMItem.model(.init(adId: adId,
                               info: info,
                               model: model,
                               requestDate: requestDate,
                               responseDate: responseDate))
}

public func adVRMItemTimeout(info: VRMMetaInfo, requestDate: Date, responseDate: Date) -> Action {
    return VRMItem.timeout(.init(info: info,
                                 requestDate: responseDate,
                                 responseDate: responseDate))
}

public func adVRMItemOtherError(info: VRMMetaInfo, requestDate: Date, responseDate: Date) -> Action {
    return VRMItem.other(.init(info: info, error: nil, requestDate: requestDate, responseDate: responseDate))
}

public func softTimeout() -> Action {
    return SoftTimeout()
}

public func hardTimeout() -> Action {
    return HardTimeout()
}

