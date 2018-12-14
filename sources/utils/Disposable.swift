//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

class Disposable {
    private var bag = [] as [Action<Void>]
    
    func append(dispose: @escaping Action<Void>) {
        bag.append(dispose)
    }
    
    func set<T>(value: T, in setter: @escaping Action<T?>) {
        setter(value)
        append { setter(nil) }
    }
    
    deinit {
        bag.reverse()
        bag.forEach { dispose in dispose(()) }
    }
}
