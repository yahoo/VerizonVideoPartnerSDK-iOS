//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public enum OpenMeasurementServiceScript {
    case none
    case recieved
    case failed(Error)
    
    public var isFailed: Bool {
        guard case .failed = self else { return false }
        return true
    }
}


func reduce(state: OpenMeasurementServiceScript, action: Action) -> OpenMeasurementServiceScript {
    switch action {
    case let action as OpenMeasurementScriptLoadingFailed:
        return OpenMeasurementServiceScript.failed(action.error)
    case is OpenMeasurementScriptRecieved:
        return OpenMeasurementServiceScript.recieved
    default: return state
    }
}

extension OpenMeasurementServiceScript: Equatable {
    public static func == (lhs: OpenMeasurementServiceScript, rhs: OpenMeasurementServiceScript) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none): return true
        case (.failed, .failed): return true
        case (.recieved, .recieved): return true
        default: return false
        }
    }
}

