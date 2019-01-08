//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreGraphics

public func updateViewportDimensions(currentSize: CGSize?, newSize: CGSize?) -> Action {
    switch (currentSize, newSize) {
    case (nil, let size?):
        return AttachToViewport(dimensions: size)
    case (.some, let new?):
        return UpdateViewportDimensions(newSize: new)
    case (.some, nil):
        return DetachFromViewport()
    default: return Nop()
    }
}
