//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import XCTest
import Quick
import Nimble
@testable import OathVideoPartnerSDK

class UserActionInitiatedTests: QuickSpec {
    override func spec() {
        context("When player props") {
            describe("user action initiated") {
                typealias ActionInitiated = Player.Properties.PlaybackItem.Video.ActionInitiated
                expect(userActionInitiated(hasTime: true,
                                           shouldPlay: true,
                                           isNotFinished: false)) == ActionInitiated.unknown
                expect(userActionInitiated(hasTime: false,
                                           shouldPlay: true,
                                           isNotFinished: false)) == ActionInitiated.unknown
                expect(userActionInitiated(hasTime: true,
                                           shouldPlay: false,
                                           isNotFinished: false)) == ActionInitiated.unknown
                expect(userActionInitiated(hasTime: true,
                                           shouldPlay: true,
                                           isNotFinished: true)) == ActionInitiated.play
                expect(userActionInitiated(hasTime: false,
                                           shouldPlay: false,
                                           isNotFinished: true)) == ActionInitiated.unknown
                expect(userActionInitiated(hasTime: true,
                                           shouldPlay: false,
                                           isNotFinished: true)) == ActionInitiated.pause
                expect(userActionInitiated(hasTime: false,
                                           shouldPlay: true,
                                           isNotFinished: true)) == ActionInitiated.unknown
                expect(userActionInitiated(hasTime: false,
                                           shouldPlay: false,
                                           isNotFinished: false)) == ActionInitiated.unknown
            }
        }
    }
}
