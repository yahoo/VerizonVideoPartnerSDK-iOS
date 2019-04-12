//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public extension VRMCore {
    static func startItemParsing(originalItem: Item, vastXML: String, startDate: Date = Date()) -> Action {
        return StartItemParsing(originalItem: originalItem, vastXML: vastXML, startDate: startDate)
    }
    
    static func completeItemParsing(originalItem: Item, vastModel: VRMCore.VASTModel) -> Action {
        return CompleteItemParsing(originalItem: originalItem, vastModel: vastModel)
    }
    
    static func failedItemParse(originalItem: Item, finishDate: Date = Date()) -> Action {
        return ParsingError(originalItem: originalItem, finishDate: finishDate)
    }
    
    static func startItemFetch(originalItem: Item, url: URL,  startDate: Date = Date()) -> Action {
        return StartItemFetch(originalItem: originalItem, url: url, startDate: startDate)
    }
    
    static func failedItemFetch(originalItem: Item, finishDate: Date = Date()) -> Action {
        return FetchingError(originalItem: originalItem, finishDate: finishDate)
    }
    
    static func unwrapItem(item: Item, url: URL) -> Action {
        return UnwrapItem(url: url, item: item)
    }
    
    static func tooManyIndirections(item: Item, finishDate: Date = Date()) -> Action {
        return TooManyIndirections(item: item, finishDate: finishDate)
    }
    
    static func otherError(item: Item, finishDate: Date = Date()) -> Action {
        return OtherError(item: item, finishDate: finishDate)
    }
}
