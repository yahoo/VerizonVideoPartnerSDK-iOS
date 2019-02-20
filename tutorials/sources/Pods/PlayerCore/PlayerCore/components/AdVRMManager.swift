//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public protocol AdVRMManagerResult {
    var transactionID: String? { get }
    var slot: String { get }
}

public typealias CostPerMille = String

public struct AdVRMManager {
    public let timeoutBarrier: Int
    
    public var requestsFired: Int
    public var request: VRMRequest
    public struct VRMRequest {
        public var id: UUID?
        public var timeout: Timeout
        public var state: State
        public enum State {
            case ready
            case progress
            case skipped(SkippedResult)
            case finish(FinishResult)
            case failed(FailedResult)
            
            public struct SkippedResult: AdVRMManagerResult {
                public var transactionID: String?
                public var slot: String
                public var startItems: Set<StartItem> = []
                public var timeoutItems: Set<TimeoutItem> = []
                public var otherErrorItems: Set<OtherErrorItem> = []
                public var completeItem: CompleteItem?
            }
            
            public struct FailedResult: AdVRMManagerResult {
                public var transactionID: String?
                public var slot: String
            }
            
            public struct FinishResult: AdVRMManagerResult {
                public let transactionID: String?
                public let slot: String
                public var startItems: Set<StartItem> = []
                public var timeoutItems: Set<TimeoutItem> = []
                public var otherErrorItems: Set<OtherErrorItem> = []
                public var completeItem: CompleteItem?
            }
        }
        
        public var result: AdVRMManagerResult? {
            switch state {
            case .skipped(let result): return result
            case .finish(let result): return result
            case .failed(let result): return result
            default: return nil
            }
        }
        
        static func initial() -> VRMRequest {
            return VRMRequest(id: nil, timeout: .beforeSoft, state: .ready)
        }
    }
    
    public enum Timeout: Hashable { case beforeSoft, afterSoft, afterHard }
    
    public struct StartItem: Hashable {
        public let info: VRMMetaInfo
        public let itemID: UUID
        public let url: URL
        public let requestDate: Date
    }
    
    public struct CompleteItem: Hashable {
        public let adId: String?
        public let itemID: UUID
        public let info: VRMMetaInfo
        public let transactionID: String?
        public let responseTime: Int
        public let timeout: Timeout
        public let requestTimeoutBarrier: Int
    }
    
    public struct TimeoutItem: Hashable {
        public let info: VRMMetaInfo
        public let itemID: UUID
        public let transactionID: String?
        public let responseTime: Int
        public let timeout: Timeout
        public let requestTimeoutBarrier: Int
    }
    
    public struct OtherErrorItem {
        public let info: VRMMetaInfo
        public let itemID: UUID
        public let transactionID: String?
        public let responseTime: Int
        public let timeout: Timeout
        public let error: Error?
    }
}

func reduce(state: AdVRMManager, action: Action) -> AdVRMManager {
    var state = state
    
    switch (action, state.request.state) {
    case (let action as AdRequest, .ready),
         (let action as AdRequest, .failed),
         (let action as AdRequest, .skipped):
        state.request = AdVRMManager.VRMRequest(id: action.id,
                                                timeout: .beforeSoft,
                                                state: .progress)
        state.requestsFired += 1
        
    case (is AdPlaybackFailed, .finish(let finish)),
         (is AdError, .finish(let finish)),
         (is AdNotSupported, .finish(let finish)),
         (is AdStartTimeout, .finish(let finish)):
        state.request.state = .failed(.init(transactionID: finish.transactionID,
                                          slot: finish.slot))
        
    case (is DropAd, .finish(let finish)):
        state.request.state = .skipped(.init(transactionID: finish.transactionID,
                                             slot: finish.slot,
                                             startItems: finish.startItems,
                                             timeoutItems: finish.timeoutItems,
                                             otherErrorItems: finish.otherErrorItems,
                                             completeItem: finish.completeItem))
        
    case (is ShowContent, .finish),
         (is AdStopped, .finish),
         (is AdMaxShowTimeout, .finish):
        state.request = .initial()
        
    case (let action as ProcessGroups, .progress):
        state = AdVRMManager(timeoutBarrier: state.timeoutBarrier,
                             requestsFired: state.requestsFired,
                             request: state.request)
        state.request.state = .finish(.init(transactionID: action.transactionId,
                                            slot: action.slot,
                                            startItems: [],
                                            timeoutItems: [],
                                            otherErrorItems: [],
                                            completeItem: nil))
        
    case (let item as VRMItem, .finish(var finish)):
        switch item {
        case .start(let start):
            finish.startItems.insert(.init(info: start.info,
                                           itemID: UUID(),
                                           url: start.url,
                                           requestDate: start.requestDate))
            
        case .model(let model):
            if state.request.timeout == .afterHard {
                finish.timeoutItems.insert(.init(info: model.info,
                                                 itemID: UUID(),
                                                 transactionID: finish.transactionID,
                                                 responseTime: responseTime(from: model.requestDate, end: model.responseDate),
                                                 timeout: state.request.timeout,
                                                 requestTimeoutBarrier: state.timeoutBarrier))
            } else {
                guard finish.completeItem == nil else { fatalError("Bad situation - multiple completed items!") }
                finish.completeItem = .init(adId: model.adId,
                                            itemID: UUID(),
                                            info: model.info,
                                            transactionID: finish.transactionID,
                                            responseTime: responseTime(from: model.requestDate, end: model.responseDate),
                                            timeout: state.request.timeout,
                                            requestTimeoutBarrier: state.timeoutBarrier)
            }
            
        case .timeout(let timeout):
            finish.timeoutItems.insert(.init(info: timeout.info,
                                             itemID: UUID(),
                                             transactionID: finish.transactionID,
                                             responseTime: responseTime(from: timeout.requestDate, end: timeout.responseDate),
                                             timeout: state.request.timeout,
                                             requestTimeoutBarrier: state.timeoutBarrier))
        case .other(let other):
            finish.otherErrorItems.insert(.init(info: other.info,
                                                itemID: UUID(),
                                                transactionID: finish.transactionID,
                                                responseTime: responseTime(from: other.requestDate, end: other.responseDate),
                                                timeout: state.request.timeout,
                                                error: other.error))
        }
        state.request.state = .finish(finish)
        
    case (is SoftTimeout, _): state.request.timeout = .afterSoft
        
    case (is HardTimeout, _): state.request.timeout = .afterHard
        
    case (is SelectVideoAtIdx, _): state.request = .initial()
        
    default: break
    }
    
    return state
}

func responseTime(from start: Date, end: Date) -> Int {
    return Int(end.timeIntervalSince(start) * 1000)
}
