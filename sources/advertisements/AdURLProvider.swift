//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import PlayerCore

struct AdURLProvider {
    let groupsFetch: (URL) -> Future<VRMProvider.Response?>
    let processItem: (VRMProvider.Item) -> Future<PlayerCore.Ad.VASTModel?>
    let softTimeoutAction: (TimeInterval, @escaping Action<Void>) -> Void
    let hardTimeoutAction: (TimeInterval, @escaping Action<Void>) -> Void
    let softTimeoutValue: TimeInterval
    let hardTimeoutValue: TimeInterval
    
    init(groupsFetch: @escaping (URL) -> Future<VRMProvider.Response?>,
         processItem: @escaping (VRMProvider.Item) -> Future<PlayerCore.Ad.VASTModel?>,
         softTimeoutAction: @escaping (TimeInterval, @escaping Action<Void>) -> Void,
         hardTimeoutAction: @escaping (TimeInterval, @escaping Action<Void>) -> Void,
         softTimeoutValue: TimeInterval,
         hardTimeoutValue: TimeInterval)
    {
        self.groupsFetch = groupsFetch
        self.processItem = processItem
        self.softTimeoutAction = softTimeoutAction
        self.hardTimeoutAction = hardTimeoutAction
        self.softTimeoutValue = softTimeoutValue
        self.hardTimeoutValue = hardTimeoutValue
    }
    
    var customUnimplementedHandler: ((Any) -> ())? = nil
    
    typealias Request = VRMRequest<VRMProvider.Item, PlayerCore.Ad.VASTModel>
    
    let queue = DispatchQueue(label: "com.VerizonVideoPartnerSDK.adurlprovider")
    
    //swiftlint:disable function_body_length
    
    func requestAd(for url: URL) -> Future<PlayerCore.Ad.VASTModel?> {
        
        let process = AdURLProviderProcess(for: url)
        
        return Future { complete in
            let request = Request(unimplementedHandler:
                self.customUnimplementedHandler ?? process.unimplementedHandler
            )
            
            var isStopped = false
            
            func stop() {
                process.didStop()
                isStopped = true
            }
            
            func requestGroups() {
                process.requestGroups()
                self.groupsFetch(url).onComplete { result in
                    if let response = result {
                        self.queue.async {
                            if !isStopped {
                                process.didReceiveGroups(response.items)
                                request.inputs.didReceiveGroups(response.items)
                                
                                self.softTimeoutAction(self.softTimeoutValue) {
                                    self.queue.async {
                                        if !isStopped {
                                            process.hitSoftTimeout()
                                            request.inputs.fireSoftTimeout()
                                        }
                                    }
                                }
                                
                                self.hardTimeoutAction(self.hardTimeoutValue) {
                                    self.queue.async {
                                        if !isStopped {
                                            process.hitHardTimeout()
                                            request.inputs.fireHardTimeout()
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        self.queue.async {
                            if !isStopped {
                                process.didFailToReceiveGroups()
                                request.inputs.didFailedToReceiveGroups()
                            }
                        }
                    }
                }
            }
            
            func processItem(item: VRMProvider.Item) {
                process.processItem(item)
                self.processItem(item).onComplete { result in
                        if let result = result {
                            self.queue.async {
                                if !isStopped {
                                    process.didProcessItem(item, to: result)
                                    request.inputs.didProcessItem((item, result))
                                }
                            }
                        } else {
                            self.queue.async {
                                if !isStopped {
                                    process.didFailToProcessItem(item)
                                    request.inputs.didFailToProcessItem(item)
                                }
                            }
                        }
                }
            }
            
            request.outputs = Request.Outputs(
                requestGroups: requestGroups,
                processItem: processItem,
                stop: stop,
                retrieveResult: { model in
                    process.didRetrieveResult(model)
                    complete(model) },
                failToRetrieveResult: {
                    process.didFailToRetrieveResult()
                    complete(nil) }
            )
            
            self.queue.async {
                process.startRequest()
                request.inputs.start()
            }
        }
    }
}
