//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import PlayerCore

class AdVRMEngine {
    let dispatcher: (PlayerCore.Action) -> Void
    
    init(dispatcher: @escaping (PlayerCore.Action) -> Void) {
        self.dispatcher = dispatcher
    }
    
    func requestAds(using request: @escaping (URL) -> Future<VRMProvider.Response?>) -> (URL) -> Future<VRMProvider.Response?> {
        return { url in
            return request(url).map { [weak self] result -> VRMProvider.Response? in
                guard let `self` = self else { return nil }
                guard let response = result else { return nil }
                self.dispatcher(PlayerCore.adProcessGroup(transactionId: response.transactionId,
                                                          slot: response.slot))
                return response
            }
        }
    }
    
    func processItem(using parseTag: @escaping (String) -> Future<VASTWrapperProcessor.Result>,
                     using fetchTag: @escaping (URL) -> Future<VASTWrapperProcessor.Result>,
                     isVPAIDAllowed: Bool) -> (VRMProvider.Item) -> Future<PlayerCore.Ad.VASTModel?> {
        return { item in
            switch item {
            case .url(let url, let meta):
                let info = VRMMetaInfo(engineType: meta.engineType,
                                       ruleId: meta.ruleId,
                                       ruleCompanyId: meta.ruleCompanyId,
                                       vendor: meta.vendor,
                                       name: meta.name,
                                       cpm: meta.cpm)
                
                let requestDate = Date()
                self.dispatcher(PlayerCore.adVRMItemStart(info: info,
                                                          url: url,
                                                          requestDate: requestDate))
                
                return fetchTag(url).map { result in
                    switch result {
                    case .model(let model):
                        return select(model: model,
                                      dispatcher: self.dispatcher,
                                      info: info,
                                      requestDate: requestDate,
                                      isVPAIDAllowed: isVPAIDAllowed)
                    case .timeoutError:
                        self.dispatcher(PlayerCore.adVRMItemTimeout(info: info,
                                                                    requestDate: requestDate,
                                                                    responseDate: Date()))
                        return nil
                    default:
                        self.dispatcher(PlayerCore.adVRMItemOtherError(info: info,
                                                                       requestDate: requestDate,
                                                                       responseDate: Date()))
                        
                        return nil
                    }
                }
                
            case .vast(let vast, _):
                return parseTag(vast).map {
                    guard case .model(let model) = $0 else { return nil }
                    return model
                }
            }
        }
    }
    
    func softTimeout() -> (TimeInterval, @escaping Action<Void>) -> Void {
        return { duration, action in
            _ = Timer(duration: duration, fire: {
                self.dispatcher(PlayerCore.softTimeout())
                action(())
            }) }
    }
    
    func hardTimeout() -> (TimeInterval, @escaping Action<Void>) -> Void {
        return { duration, action in
            _ = Timer(duration: duration, fire: {
                self.dispatcher(PlayerCore.hardTimeout())
                action(())
            })
        }
    }
}

func select(model: PlayerCore.Ad.VASTModel,
            dispatcher: (PlayerCore.Action) -> (),
            info: VRMMetaInfo,
            requestDate: Date,
            isVPAIDAllowed: Bool) -> PlayerCore.Ad.VASTModel? {
    let isModelContainsAds = (isVPAIDAllowed && !model.vpaidMediaFiles.isEmpty) || !model.mp4MediaFiles.isEmpty
    guard isModelContainsAds else {
        dispatcher(PlayerCore.adVRMItemOtherError(info: info,
                                                  requestDate: requestDate,
                                                  responseDate: Date()))
        return nil
    }
    dispatcher(PlayerCore.adVRMItemResponse(adId: model.id,
                                            info: info,
                                            model: model,
                                            requestDate: requestDate,
                                            responseDate: Date()))
    return model
}
