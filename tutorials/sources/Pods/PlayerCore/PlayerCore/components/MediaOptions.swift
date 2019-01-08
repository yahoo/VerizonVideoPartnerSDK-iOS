//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public struct MediaOptions {
    public struct Option: Equatable {
        public let uuid: UUID
        public let displayName: String
        
        public static func ==(lhs: MediaOptions.Option, rhs: MediaOptions.Option) -> Bool {
            return lhs.uuid == rhs.uuid && lhs.displayName == rhs.displayName
        }
        
        public init(uuid: UUID, displayName: String) {
            self.uuid = uuid
            self.displayName = displayName
        }
    }
    
    public static let empty = MediaOptions(unselectedAudibleOptions: [],
                                           selectedAudibleOption: nil,
                                           unselectedLegibleOptions: [],
                                           selectedLegibleOption: nil)
    
    public var unselectedAudibleOptions: [Option] = []
    public var selectedAudibleOption: Option? = nil
    
    public var unselectedLegibleOptions: [Option] = []
    public var selectedLegibleOption: Option? = nil
    
    public init(unselectedAudibleOptions: [Option],
                selectedAudibleOption: Option?,
                unselectedLegibleOptions: [Option],
                selectedLegibleOption: Option?) {
        self.unselectedAudibleOptions = unselectedAudibleOptions
        self.selectedAudibleOption = selectedAudibleOption
        self.unselectedLegibleOptions = unselectedLegibleOptions
        self.selectedLegibleOption = selectedLegibleOption
    }
}

func reduce(state: MediaOptions, action: Action) -> MediaOptions {
    var state = state
    
    switch action {
    case let action as UpdateAvailableAudibleOptions:
        state.unselectedAudibleOptions = action.options
    
    case let action as UpdateAvailableLegibleOptions:
        state.unselectedLegibleOptions = action.options
        
    case let action as SelectAudibleOption:
        state.selectedAudibleOption = action.option
        
    case let action as SelectLegibleOption:
        state.selectedLegibleOption = action.option
        
    default: break
    }
    
    return state
}
