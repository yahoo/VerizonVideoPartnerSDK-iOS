//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func next(currentIdx: Int, prerolls: [Int], midrolls: [[Midroll]]) -> Action {
    let nextIndex = currentIdx + 1
    return selectVideoAtIndex(idx: nextIndex, prerolls: prerolls, midrolls: midrolls)
}
