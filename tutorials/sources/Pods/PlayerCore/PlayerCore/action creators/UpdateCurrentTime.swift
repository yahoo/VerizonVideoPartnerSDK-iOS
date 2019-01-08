//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreMedia

public func updateContentCurrentTime(time: CMTime, date: Date) -> Action {
    return UpdateContentCurrentTime(newTime: time, currentDate: date)
}

public func updateAdCurrentTime(time: CMTime) -> Action {
    return UpdateAdCurrentTime(newTime: time)
}
