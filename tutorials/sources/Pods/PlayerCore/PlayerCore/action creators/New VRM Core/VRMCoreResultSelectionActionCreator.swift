//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public extension VRMCore {
    static func selectInlineVAST(item: Item, inlineVAST: Ad.VASTModel, date: Date = Date()) -> Action {
        return SelectInlineItem(item: item, inlineVAST: inlineVAST, date: date)
    }
    
    static func selectFinalResult(item: Item, inlineVAST: Ad.VASTModel) -> Action {
        return SelectFinalResult(item: item, inlineVAST: inlineVAST)
    }
}
