//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

class Observable<Value> {
    private let queue: DispatchQueue
    
    var value: Value {
        didSet {
            queue.async {
                self.observers.forEach { $0.fireUpdate(self.value) }
            }
        }
    }
    
    var observers: Set<Observer<Value>>
    
    init(value: Value, queue: DispatchQueue) {
        self.queue = queue
        self.value = value
        self.observers = []
    }
    
    func addObserver(on queue: DispatchQueue = .main,
                     mode: ObservationMode = .throttleUpdates,
                     _ observer: @escaping (Value) -> Void) -> () -> Void {
        let observer = Observer(callback: observer,
                                queue: queue,
                                mode: mode)
        self.queue.async { [weak self] in
            guard let `self` = self else { return }
            
            self.observers.insert(observer)
            observer.fireUpdate(self.value)
        }
        
        return { [weak self] in
            self?.queue.sync {
                _ = self?.observers.remove(observer)
                observer.fireUpdate(nil)
            }
        }
    }
}
