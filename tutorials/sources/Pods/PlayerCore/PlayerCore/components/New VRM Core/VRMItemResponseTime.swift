//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct VRMItemResponseTime {
    typealias Container = [VRMCore.Item: TimeRange]
    
    static let initial = VRMItemResponseTime(timeRangeContainer: [:])
    
    public struct TimeRange: Hashable {
        public let startAt: Date
        public let finishAt: Date?
    }
    
    public let timeRangeContainer: [VRMCore.Item: TimeRange]
}

func reduce(state: VRMItemResponseTime, action: Action) -> VRMItemResponseTime {
    
    func updateFinishTime(for item: VRMCore.Item,
                          with date: Date,
                          in container: VRMItemResponseTime.Container) -> VRMItemResponseTime {
        guard let range = container[item] else {
            fatalError("get finish error action for item which wasn't started")
        }
        
        var newTimeContainer = container
        newTimeContainer[item] = .init(startAt: range.startAt, finishAt: date)
        return VRMItemResponseTime(timeRangeContainer: newTimeContainer)
    }
    
    func updateStartTime(for item: VRMCore.Item,
                         with date: Date) -> VRMItemResponseTime {
        var newTimeContainer = state.timeRangeContainer
        newTimeContainer[item] = .init(startAt: date, finishAt: nil)
        return VRMItemResponseTime(timeRangeContainer: newTimeContainer )
    }
    
    switch action {
    case let failedFetch as VRMCore.FetchingError:
        return updateFinishTime(for: failedFetch.originalItem,
                                with: failedFetch.finishDate,
                                in: state.timeRangeContainer)
        
    case let failedParse as VRMCore.ParsingError:
        return updateFinishTime(for: failedParse.originalItem,
                                with: failedParse.finishDate,
                                in: state.timeRangeContainer)
        
    case let indirectionError as VRMCore.TooManyIndirections:
        return updateFinishTime(for: indirectionError.item,
                                with: indirectionError.finishDate,
                                in: state.timeRangeContainer)
        
    case let selectInlineVAST as VRMCore.SelectInlineItem:
        return updateFinishTime(for: selectInlineVAST.item,
                                with: selectInlineVAST.date,
                                in: state.timeRangeContainer)
        
    case let otherError as VRMCore.OtherError:
        return updateFinishTime(for: otherError.item,
                                with: otherError.finishDate,
                                in: state.timeRangeContainer)
        
    case let startFetching as VRMCore.StartItemFetch:
        return updateStartTime(for: startFetching.originalItem,
                               with: startFetching.startDate)
        
    case let startParsing as VRMCore.StartItemParsing where state.timeRangeContainer[startParsing.originalItem] == nil:
        return updateStartTime(for: startParsing.originalItem,
                               with: startParsing.startDate)
        
    case let hardTimeout as VRMCore.HardTimeout:
        return hardTimeout.items.reduce(state) { result, item in
            updateFinishTime(for: item,
                             with: hardTimeout.date,
                             in: result.timeRangeContainer)
        }
        
    default: return state
    }
}
