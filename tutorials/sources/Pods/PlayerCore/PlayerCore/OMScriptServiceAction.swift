//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

struct OpenMeasurementScriptRecieved: Action {}
struct OpenMeasurementScriptLoadingFailed: Action {
    let error: Error
}
