//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

/// Operator for chaining calls in pipeline manner
precedencegroup Pipe {
    higherThan: AssignmentPrecedence
    associativity: left
}

infix operator |> : Pipe

/// Connect two throwing calls into one.
func |> <T, U, V> (
    left: @escaping (T) throws -> U,
    right: @escaping (U) throws -> V)
    -> ((T) throws -> V) {
        return { arguments in
            return try right(left(arguments))
        }
}

/// Apply argument to the function.
func |> <T, U> (value: T, function: (T) throws -> U) rethrows -> U {
    return try function(value)
}

/// Connect two calls into one.
func |> <T, U, V> (
    left: @escaping (T) -> U,
    right: @escaping (U) -> V)
    -> ((T) -> V) {
        return { arguments in
            right(left(arguments))
        }
}
