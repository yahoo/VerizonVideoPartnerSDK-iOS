//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public struct Thumbnail {
    let width: Float
    let height: Float
    let url: URL
    
    public init(width: Float, height: Float, url: URL) {
        self.width = width
        self.height = height
        self.url = url
    }
}
