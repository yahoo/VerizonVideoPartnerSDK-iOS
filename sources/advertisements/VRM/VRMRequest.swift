//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

class VRMRequest<Item: Hashable, Result> {
    
    struct Inputs {
        var start: ActionWithVoid
        var cancel: ActionWithVoid
        var didReceiveGroups: Action<[[Item]]>
        var didFailedToReceiveGroups: ActionWithVoid
        var didProcessItem: Action<(Item, Result)>
        var didFailToProcessItem: Action<Item>
        var fireSoftTimeout: ActionWithVoid
        var fireHardTimeout: ActionWithVoid
    }
    
    struct Outputs {
        var requestGroups: ActionWithVoid
        var processItem: Action<Item>
        var stop: ActionWithVoid
        var retrieveResult: Action<Result>
        var failToRetrieveResult: ActionWithVoid
    }

    private enum Status { case inProgress, failed, success(Result) }
    
    private let unimplementedHandler: Action<Any>
    
    private let defaultInputs: Inputs
    private let defaultOutputs: Outputs
    
    init(unimplementedHandler: @escaping Action<Any>) {
        self.unimplementedHandler = unimplementedHandler
        
        defaultInputs = Inputs(
            start: unimplementedHandler,
            cancel: unimplementedHandler,
            didReceiveGroups: unimplementedHandler,
            didFailedToReceiveGroups: unimplementedHandler,
            didProcessItem: unimplementedHandler,
            didFailToProcessItem: unimplementedHandler,
            fireSoftTimeout: unimplementedHandler,
            fireHardTimeout: unimplementedHandler
        )
        
        defaultOutputs = Outputs(
            requestGroups: unimplementedHandler,
            processItem: unimplementedHandler,
            stop: unimplementedHandler,
            retrieveResult: unimplementedHandler,
            failToRetrieveResult: unimplementedHandler)
        
        inputs = defaultInputs
        outputs = defaultOutputs
        
        self.inputs.start = {
            
            self.inputs.start = { self.unimplementedHandler(()) }
            
            defer {
                self.outputs.requestGroups()
            }
            
            self.inputs.cancel = self.stop
            self.inputs.didFailedToReceiveGroups = self.stop
            self.inputs.fireHardTimeout = self.stop
            
            self.inputs.fireSoftTimeout = {
                self.inputs.fireSoftTimeout = { self.unimplementedHandler(()) }
                self.isHardMode = true
            }
            
            self.inputs.didReceiveGroups = { groups in
                self.inputs.didReceiveGroups = { _ in self.unimplementedHandler(()) }
                self.process(groups: groups)
            }
        }
    }
    
    private(set) var inputs: Inputs
    var outputs: Outputs
    
    private func stop() {
        inputs = defaultInputs
        outputs.stop()
        outputs.failToRetrieveResult()
        outputs = defaultOutputs
    }
    
    private func complete(with result: Result) {
        inputs = defaultInputs
        outputs.stop()
        outputs.retrieveResult(result)
        outputs = defaultOutputs
    }
    
    private static func softModeStatus(in list: [Status]) -> Status {
        for status in list {
            switch status {
            case .inProgress, .success: return status
            case .failed: break }
        }
        
        // We can reach this point if and only if all statuses are .Failed
        return .failed
    }
    
    private static func hardModeStatus(in list: [Status]) -> Status {
        var hasItemsInProgress = false
        
        for status in list {
            switch status {
            case .inProgress: hasItemsInProgress = true
            case .success: return status // first success is ok
            case .failed: break }
        }
        
        // We can reach this point if no success
        return hasItemsInProgress
            ? .inProgress
            : .failed
    }
    
    private var isHardMode = false
    
    func process(groups: [[Item]]) { //swiftlint:disable:this function_body_length
        guard groups.count > 0 else { return self.stop() }
        let activeGroup = groups[0]
        
        var groupStatus = [:] as [Item: Status]
        
        activeGroup.forEach { item in groupStatus[item] = Status.inProgress }
        defer { activeGroup.forEach { item in self.outputs.processItem(item) } }
        
        func handleNewGroupStatus() {
            let statuses = activeGroup.map {
                guard let status = groupStatus[$0] else {
                    fatalError("Item: \($0) status in group: \(groupStatus) mismatch")
                }
                
                return status
                } as [Status]
            let status = isHardMode
                ? VRMRequest.hardModeStatus(in: statuses)
                : VRMRequest.softModeStatus(in: statuses)
            
            switch status {
            case .inProgress: break
            case .failed:
                let newGroups = Array(groups.dropFirst())
                process(groups: newGroups)
                
            case let .success(result):
                self.complete(with: result) }
        }

        func verifyStatusUpdate(for item: Item) {
            guard let currentStatus = groupStatus[item] else {
                fatalError("Unexpected item: \(item)")
            }
            guard case Status.inProgress = currentStatus else {
                fatalError("Unexpected update of item: \(item) status")
            }
        }
        
        self.inputs.fireSoftTimeout = {
            self.inputs.fireSoftTimeout = { self.unimplementedHandler(()) }
            self.isHardMode = true
            handleNewGroupStatus()
        }

        self.inputs.didProcessItem = { arg in
            let (item, result) = arg
            verifyStatusUpdate(for: item)
            groupStatus[item] = Status.success(result)
            handleNewGroupStatus()
        }
        
        self.inputs.didFailToProcessItem = { item in
            verifyStatusUpdate(for: item)
            groupStatus[item] = Status.failed
            handleNewGroupStatus()
        }
    }
}
