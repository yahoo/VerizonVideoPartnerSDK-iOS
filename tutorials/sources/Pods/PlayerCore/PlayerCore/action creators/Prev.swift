//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func prev(currentIdx: Int, prerolls: [Int], midrolls: [[Midroll]]) -> Action {
    let prevIndex = currentIdx - 1
    return selectVideoAtIndex(idx: prevIndex, prerolls: prerolls, midrolls: midrolls)
}
