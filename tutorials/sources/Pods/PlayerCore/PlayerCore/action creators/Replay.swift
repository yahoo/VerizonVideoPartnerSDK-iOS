//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func replay(currentIndex: Int, prerolls: [Int], midrolls: [[Midroll]]) -> Action {
    return selectVideoAtIndex(idx: currentIndex, prerolls: prerolls, midrolls: midrolls)
}
