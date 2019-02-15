//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public extension VRMCore {
    public static func startItemParsing(originalItem: Item, vastXML: String, startDate: Date = Date()) -> Action {
        return StartItemParsing(originalItem: originalItem, vastXML: vastXML, startDate: startDate)
    }
    
    public static func completeItemParsing(originalItem: Item, vastModel: VRMCore.VASTModel) -> Action {
        return CompleteItemParsing(originalItem: originalItem, vastModel: vastModel)
    }
    
    public static func failedItemParse(originalItem: Item, finishDate: Date = Date()) -> Action {
        return ParsingError(originalItem: originalItem, finishDate: finishDate)
    }
    
    public static func startItemFetch(originalItem: Item, url: URL,  startDate: Date = Date()) -> Action {
        return StartItemFetch(originalItem: originalItem, url: url, startDate: startDate)
    }
    
    public static func failedItemFetch(originalItem: Item, finishDate: Date = Date()) -> Action {
        return FetchingError(originalItem: originalItem, finishDate: finishDate)
    }
    
    public static func unwrapItem(item: Item, url: URL) -> Action {
        return UnwrapItem(url: url, item: item)
    }
    
    public static func tooManyIndirections(item: Item, finishDate: Date = Date()) -> Action {
        return TooManyIndirections(item: item, finishDate: finishDate)
    }
    
    public static func otherError(item: Item, finishDate: Date = Date()) -> Action {
        return OtherError(item: item, finishDate: finishDate)
    }
}
