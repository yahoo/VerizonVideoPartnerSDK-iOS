//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public func failedOMConfiguration(with error: Error) -> Action {
    return OpenMeasurementConfigurationFailed(error: error)
}
public func openMeasurementActivated(adEvents: OpenMeasurement.AdEvents,
                                     videoEvents: OpenMeasurement.VideoEvents) -> Action {
    return OpenMeasurementActivated(adEvents: adEvents,
                                    videoEvents: videoEvents)
}
public func openMeasurementDeactivated() -> Action {
    return OpenMeasurementDeactivated()
}
