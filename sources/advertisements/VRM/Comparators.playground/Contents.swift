//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

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

let a = ["1"]
let b = ["1", "2"]

a == b

func ==(lhs: [[String : String]], rhs: [[String : String]]) -> Bool {
    for l in lhs {
        for r in rhs {
            return l == r
        }
    }
    return true
}

let c = [["key" : "value"]]
let d = [["key" : "value"]]

c == d


func ==(lhs : [String : Any], rhs: [String : Any]) -> Bool {
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
    return true
}


func ==(lhs: [[[String : Any]]], rhs: [[[String : Any]]]) -> Bool {
    for l1 in lhs {
        for l2 in l1 {
            for r1 in rhs {
                for r2 in r1 {
                    return l2 == r2
                }
            }
        }
    }
    return true
}

let e = [[["key": "value" as Any]]]
let f = [[["key": "value" as Any]]]

e == f
