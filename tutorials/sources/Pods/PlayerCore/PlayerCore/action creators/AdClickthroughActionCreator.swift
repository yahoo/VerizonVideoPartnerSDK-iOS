//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
public func requestClickthroughAdPresentation() -> Action {
    return RequestClickthroughAdPresentation()
}

public func didShowAdClickthrough() -> Action {
    return DidShowAdClickthrough()
}

public func didHideAdClickthrough(isAdVPAID: Bool) -> Action {
    return DidHideAdClickthrough(isAdVPAID: isAdVPAID)
}
