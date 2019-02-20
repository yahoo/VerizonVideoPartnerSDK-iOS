//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

extension VRMCore {
    
    struct StartItemParsing: Action {
        let originalItem: Item
        let vastXML: String
        let startDate: Date
    }
    
    struct CompleteItemParsing: Action {
        let originalItem: Item
        let vastModel: VASTModel
    }
    
    struct ParsingError: Action {
        let originalItem: Item
        let finishDate: Date
    }
    
    struct StartItemFetch: Action {
        let originalItem: Item
        let url: URL
        let startDate: Date
    }
    
    struct FetchingError: Action {
        let originalItem: Item
        let finishDate: Date
    }
    
    struct UnwrapItem: Action {
        let url: URL
        let item: Item
    }
    
    struct TooManyIndirections: Action {
        let item: Item
        let finishDate: Date
    }
    
    struct OtherError: Action {
        let item: Item
        let finishDate: Date
    }
}
