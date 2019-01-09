//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public func updateContentDuration(duration: CMTime) -> Action {
    return UpdateContentDuration(newDuration: duration)
}

public func updateAdDuration(duration: CMTime) -> Action {
    return UpdateAdDuration(newDuration: duration)
}
