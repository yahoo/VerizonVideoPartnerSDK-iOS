//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

public protocol Cancellable {
    func cancel()
}

public final class Timer: Cancellable {
    private var timer: Foundation.Timer!
    private let fire: Action<Void>
    
    public init(duration: TimeInterval, fire: @escaping Action<Void>) {
        self.fire = fire
        self.timer = Foundation.Timer(timeInterval: duration,
                                      target: self,
                                      selector: #selector(onFire),
                                      userInfo: nil,
                                      repeats: false)
        // http://bynomial.com/blog/?p=67
        RunLoop.main.add(self.timer, forMode: RunLoop.Mode.common)
    }
    
    @objc private func onFire() {
        fire(())
    }
    
    public func cancel() {
        timer.invalidate()
    }
}
