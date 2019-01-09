//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

struct SelectVideoAtIdx: Action {
    let idx: Int
    let id: UUID
    let hasPrerollAds: Bool
    let midrolls: [Ad.Midroll]
}
