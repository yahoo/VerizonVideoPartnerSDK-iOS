//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

func onQueue<T>(_ queue: DispatchQueue) -> (@escaping Action<T>) -> Action<T> {
    return { function in
        return { arguments in
            queue.async {
                function(arguments)
            }
        }
    }
}

/// Wrap some closure to execute on main thread only.
public func onUIThread<T>(_ function: @escaping Action<T>) -> Action<T> {
    return { params in
        DispatchQueue.main.async {
            function(params)
        }
    }
}

/// Wrap some closure to execute on main thread only. Optional ready.
public func onUIThread<T>(_ function: @escaping Action<T?>) -> Action<T?> {
    return { params in
        DispatchQueue.main.async {
            function(params)
        }
    }
}
