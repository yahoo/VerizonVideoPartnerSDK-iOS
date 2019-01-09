//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct Midroll {
    let cuePoint: Int
    let url: URL
    
    public init(cuePoint: Int, url: URL) {
        self.cuePoint = cuePoint
        self.url = url
    }
}

public func selectVideoAtIndex(idx: Int, prerolls: [Int], midrolls: [[Midroll]]) -> Action {
    let hasPrerollAds: Bool = {
        guard idx < prerolls.count else { return false }
        return prerolls[idx] > 0
    }()
    
    let midrolls: [Ad.Midroll] = {
        guard idx < midrolls.count else { return [] }
        return midrolls[idx].map { Ad.Midroll(cuePoint: $0.cuePoint, url: $0.url, id: UUID()) }
    }()
    
    return SelectVideoAtIdx(idx: idx, id: UUID(), hasPrerollAds: hasPrerollAds, midrolls: midrolls)
}

