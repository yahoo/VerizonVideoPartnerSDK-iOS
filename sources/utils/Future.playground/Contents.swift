//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import OathVideoPartnerSDK
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


let f = Future<Int> { promise in
    DispatchQueue.global().async {
        promise(10)
    }
}

f.onComplete { value in
    print(value)
}

f.map { $0 + 2 }.onComplete { print($0) }

