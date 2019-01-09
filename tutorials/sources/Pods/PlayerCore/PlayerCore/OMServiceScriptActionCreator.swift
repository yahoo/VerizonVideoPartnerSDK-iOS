//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

public func failedOMScriptLoading(with error: Error) -> Action {
    return OpenMeasurementScriptLoadingFailed(error: error)
}
public func recievedOMScript() -> Action {
    return OpenMeasurementScriptRecieved()
}
