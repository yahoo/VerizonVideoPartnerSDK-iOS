//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
//swiftlint:disable variable_name
func memoise<T: Equatable, U>(f: @escaping (T) -> U) -> ((T) -> U) {
    var old: T? = nil
    var oldResult: U? = nil
    return { new in
        if new == old {
            return oldResult!
        } else {
            old = new
            oldResult = f(new)
            return oldResult!
        }
    }
}
