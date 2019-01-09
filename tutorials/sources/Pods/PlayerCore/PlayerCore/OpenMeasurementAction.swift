//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

struct OpenMeasurementActivated: Action {
    let adEvents: OpenMeasurement.AdEvents
    let videoEvents: OpenMeasurement.VideoEvents
}
struct OpenMeasurementConfigurationFailed: Action {
    let error: Error
}
struct OpenMeasurementDeactivated: Action { }
