//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum ObservationMode {
    
    /// In this mode every update will be delivered to observer.
    /// Even if update was scheduled before unsubscription.
    case everyUpdate
    
    /// In this mode observer will throttle props.
    /// In short: it will lead to situation when only last from sequential updates will be delivered
    /// Also no updates will be delivered after removing from observation pool.
    case throttleUpdates
}

class Observer<Value>: Hashable {
    typealias Callback = (Value) -> Void
    typealias Update = (Value?) -> Void
    
    let fireUpdate: Update
    
    private init(fireUpdate: @escaping Update) {
        self.fireUpdate = fireUpdate
    }
    
    init(callback: @escaping Callback, queue: DispatchQueue, mode: ObservationMode) {
        switch mode {
        case .everyUpdate: fireUpdate = Observer.makeEveryObserver(callback: callback, queue: queue)
        case .throttleUpdates: fireUpdate = Observer.makeThrottleObserver(callback: callback, queue: queue)
        }
    }
    
    static func makeThrottleObserver(callback: @escaping Callback,
                                     queue callbackQueue: DispatchQueue) -> Update {
        
        /// Queue for protecting access to pending props
        let queue = DispatchQueue(label: "com.VerizonVideoPartnerSDK.player.observer")
        
        /// Intermediate storage for props
        var pending: Value?
        
        return { value in
            queue.sync {
                let isRunningCallbackNeeded = pending == nil && value != nil
                pending = value
                guard isRunningCallbackNeeded else { return }
                
                callbackQueue.async {
                    var value: Value?
                    queue.sync {
                        value = pending
                        pending = nil
                    }
                    value.map(callback)
                }
            }
        }
    }
    
    static func makeEveryObserver(callback: @escaping Callback,
                                  queue: DispatchQueue) -> Update  {
        return { value in
            guard let value = value else { return }
            queue.async { callback(value) }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(ObjectIdentifier(self))
    }
    
    static func ==(lhs: Observer, rhs: Observer) -> Bool {
        return lhs === rhs
    }
}
