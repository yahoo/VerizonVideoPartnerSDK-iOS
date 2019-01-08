//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import CoreGraphics

public struct Viewport {
    public let dimensions: CGSize?
    public let camera: Angles
    
    public struct Angles {
        public let horizontal: Float
        public let vertical: Float
    }
}

func reduce(state: Viewport, action: Action) -> Viewport {
    switch action {
    case let action as AttachToViewport:
        return Viewport(dimensions: action.dimensions, camera: state.camera)
        
    case let action as UpdateViewportDimensions:
        return Viewport(dimensions: action.newSize, camera: state.camera)
        
    case is DetachFromViewport:
        return Viewport(dimensions: nil, camera: .init(horizontal: 0, vertical: 0))
    
    case let update as UpdateCameraAngles:
        return Viewport(dimensions: state.dimensions,
                        camera: .init(horizontal: update.horizontal, vertical: update.vertical))
        
    default: return state
    }
}
