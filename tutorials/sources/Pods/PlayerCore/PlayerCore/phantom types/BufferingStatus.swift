//  Copyright 2019, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum BufferingStatus {
    case inProgress(startAt: Date)
    case finished(startAt: Date, finishAt: Date)
    case empty
}
