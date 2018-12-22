//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

@testable import PlayerCore

struct ActionComparator<ActionType> {
    let compareBlock: (ActionType, ActionType) -> Bool
    
    func compare(first: PlayerCore.Action, second: PlayerCore.Action) -> Bool {
        guard let first = first as? ActionType,
            let second = second as? ActionType else { return false }
        
        return compareBlock(first, second)
    }
}
