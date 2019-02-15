//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

extension VRMCore {
    struct SelectInlineItem: Action {
        let item: Item
        let inlineVAST: Ad.VASTModel
        let date: Date
    }
    
    struct SelectFinalResult: Action {
        let item: Item
        let inlineVAST: Ad.VASTModel
    }
}
