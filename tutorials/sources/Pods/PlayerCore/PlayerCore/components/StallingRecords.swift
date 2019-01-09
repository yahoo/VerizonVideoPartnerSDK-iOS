//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

struct StallRecord {
    let from: Date
    let to: Date
}

struct StallingRecords {
    let currentStallStartTime: Date?
    let records: [StallRecord]
}

func reduce(state: StallingRecords, action: Action) -> StallingRecords {
    switch action {
    case is SelectVideoAtIdx:
        return StallingRecords(currentStallStartTime: nil, records: [])
        
    // Where is the buffering actions?
    
    default:
        return state
    }
}
