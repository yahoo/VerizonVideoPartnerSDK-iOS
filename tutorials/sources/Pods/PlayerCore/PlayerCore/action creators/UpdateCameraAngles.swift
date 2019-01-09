//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func updateCameraAngles(horizontal: Float, vertical: Float) -> Action {
    return UpdateCameraAngles(
        horizontal: horizontal,
        vertical: .init(max(-.pi / 2, min(.init(vertical), Double.pi / 2))))
}
