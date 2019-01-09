//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
func call<T>(_ value: T) -> (@escaping Action<T>) -> Action<T> {
    return { function in call(function, value: value) }
}

func call<T>(_ function: @escaping Action<T>, value: T) -> Action<T> {
    function(value)
    return function
}

func execute<T>(_ function: () -> T) -> T {
    return function()
}
