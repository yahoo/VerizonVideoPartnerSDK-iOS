//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct VRMRequestStatus {
    static let initial = VRMRequestStatus(request: .none, requestsFired: 0)
    
    public enum Request {
        case none
        case request(url: URL, id: UUID)
    }
    
    public let request: Request
    public let requestsFired: Int
}

func reduce(state: VRMRequestStatus, action: Action) -> VRMRequestStatus {
    switch action {
    case let adRequest as VRMCore.AdRequest:
        return VRMRequestStatus(request: .request(url: adRequest.url,
                                                  id: adRequest.id),
                                requestsFired: state.requestsFired+1)
    default:
        return state
    }
}
