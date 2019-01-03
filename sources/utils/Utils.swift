//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import struct PlayerCore.Progress
@testable import VerizonVideoPartnerSDK

enum Utils {
    static func data(
        for bundleClass: AnyClass,
        with resourceName: String,
        of type: String) -> Data? {
        let bundle = Bundle(for: bundleClass)
        let filePath = bundle.url(forResource: resourceName, withExtension: type)
        let data = try? Data(contentsOf: filePath!)
        return data
    }
}

func ==(lhs: [String], rhs: [String]) -> Bool {
    for l in lhs {
        for r in rhs {
            if l != r {
                return false
            }
        }
    }
    return true
}

func ==(lhs: [[String : String]], rhs: [[String : String]]) -> Bool {
    for l in lhs {
        for r in rhs {
            if l != r {
                return false
            }
        }
    }
    return true
}

func ==(lhs : JSON, rhs: JSON) -> Bool {
    for (lk, lv) in lhs {
        for (rk, rv) in rhs {
            guard lk == rk else { return false }
            if let elv = lv as? String, let erv = rv as? String {
                return elv == erv
            } else {
                return false
            }
        }
    }
    fatalError("Incorrect equality operator implementation!")
}

func ==(lhs: [JSON], rhs: [JSON]) -> Bool {
    for l in lhs {
        for r in rhs {
            return l == r
        }
    }
    fatalError("Incorrect equality operator implementation!")
}

func ==(lhs: [[JSON]], rhs: [[JSON]]) -> Bool {
    for l1 in lhs {
        for l2 in l1 {
            for r1 in rhs {
                for r2 in r1 {
                    return l2 == r2
                }
            }
        }
    }
    fatalError("Incorrect equality operator implementation!")
}
