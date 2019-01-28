//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

func mapGroups(from itemsArray: [[VRMProvider.Item]] ) -> [VRMCore.Group] {
    return itemsArray.map { group in
        let transformedItems = group.map { item -> VRMCore.Item in
            switch item {
            case let .url(url, metainfo):
                return VRMCore.Item(source: .url(url),
                                    metaInfo: .init(engineType: metainfo.engineType,
                                                    ruleId: metainfo.ruleId,
                                                    ruleCompanyId: metainfo.ruleCompanyId,
                                                    vendor: metainfo.vendor,
                                                    name: metainfo.name,
                                                    cpm: metainfo.cpm))
            case let .vast(vastString, metainfo):
                return VRMCore.Item(source: .vast(vastString),
                                    metaInfo: .init(engineType: metainfo.engineType,
                                                    ruleId: metainfo.ruleId,
                                                    ruleCompanyId: metainfo.ruleCompanyId,
                                                    vendor: metainfo.vendor,
                                                    name: metainfo.name,
                                                    cpm: metainfo.cpm))
                
            }
        }
        return VRMCore.Group(items: transformedItems)
    }
}

final class VRMRequestController {
    typealias ResponseFetcher = (URL) -> Future<VRMProvider.Response?>
    typealias GroupsMapper = ([[VRMProvider.Item]]) -> ([VRMCore.Group])
    
    let dispatch: (PlayerCore.Action) -> Void
    let fetchVRMResponse: ResponseFetcher
    let groupsMapper: GroupsMapper
    
    private var firedRequests = Set<UUID>()
    
    init(dispatch: @escaping (PlayerCore.Action) -> Void,
         groupsMapper: @escaping GroupsMapper,
         fetchVRMResponse: @escaping ResponseFetcher ) {
        self.dispatch = dispatch
        self.fetchVRMResponse = fetchVRMResponse
        self.groupsMapper = groupsMapper
    }
    
    func process(with state: PlayerCore.State ) {
        process(with: state.vrmRequestStatus.request)
    }
    
    func process(with request: PlayerCore.VRMRequestStatus.Request?) {
        
        if let request = request,
            firedRequests.contains(request.id) == false {
            
            firedRequests.insert(request.id)
            weak var weakSelf = self
            fetchVRMResponse(request.url).onComplete { response in
                guard let response = response,
                    let `self` = weakSelf else {
                        weakSelf?.dispatch(VRMCore.adResponseFetchFailed(requestID: request.id))
                        return
                }
                weakSelf?.dispatch(VRMCore.adResponse(transactionId: response.transactionId,
                                                      slot: response.slot,
                                                      groups: self.groupsMapper(response.items)))
            }
        }
    }
}
