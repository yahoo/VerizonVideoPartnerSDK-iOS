//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.


public func update(availableAudibleOptions options: [MediaOptions.Option]) -> Action {
    return UpdateAvailableAudibleOptions(options: options)
}

public func select(audibleOption: MediaOptions.Option?) -> Action {
    return SelectAudibleOption(option: audibleOption)
}

public func update(availableLegibleOptions options: [MediaOptions.Option]) -> Action {
    return UpdateAvailableLegibleOptions(options: options)
}

public func select(legibleOption: MediaOptions.Option?) -> Action {
    return SelectLegibleOption(option: legibleOption)
}

