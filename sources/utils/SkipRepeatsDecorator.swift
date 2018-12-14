//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
func skipRepeats<T: Equatable>(function: @escaping Action<T>) -> Action<T> {
    var lastValue: T?
    return { newValue in
        guard lastValue != newValue else { return }
        lastValue = newValue
        function(newValue)
    }
}
