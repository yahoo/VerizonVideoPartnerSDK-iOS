//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

struct UpdateAvailableAudibleOptions: Action {
    let options: [MediaOptions.Option]
}

struct SelectAudibleOption: Action {
    let option: MediaOptions.Option?
}

struct UpdateAvailableLegibleOptions: Action {
    let options: [MediaOptions.Option]
}

struct SelectLegibleOption: Action {
    let option: MediaOptions.Option?
}

