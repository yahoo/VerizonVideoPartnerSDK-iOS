//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

func rethrow<T, U>(
    _ errorMap: @escaping (Error) -> Error,
    from function: @escaping (T) throws -> U) -> (T) throws -> U {
    return { input in
        do {
            return try function(input)
        } catch let error {
            throw errorMap(error)
        }
    }
} 
