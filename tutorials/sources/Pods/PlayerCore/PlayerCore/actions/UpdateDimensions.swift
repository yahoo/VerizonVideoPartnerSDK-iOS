//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreGraphics

struct AttachToViewport: Action {
    let dimensions: CGSize
}

struct UpdateViewportDimensions: Action {
    let newSize: CGSize
}

struct DetachFromViewport: Action {}
