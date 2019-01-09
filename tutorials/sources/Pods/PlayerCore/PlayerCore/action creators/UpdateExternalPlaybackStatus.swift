//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func update(externalPlaybackStatus isActive: Bool) -> Action {
    return isActive ?
        UpdateExternalPlaybackActive() :
        UpdateExternalPlaybackInactive()
}
