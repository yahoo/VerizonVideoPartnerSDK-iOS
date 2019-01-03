//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

/// Enum with typealiases available globally.
// swiftlint:disable type_name
public enum VVP {
    /// SDK shorthand.
    public typealias SDK = VerizonVideoPartnerSDK.VVPSDK
    /// Player shorthand.
    public typealias Player = VerizonVideoPartnerSDK.Player
    /// Content Video Playback Events shorthand.
    public typealias PlaybackEvents = VerizonVideoPartnerSDK.PlaybackEvents
    
    #if os(iOS)
    /// Player View Controller shorthand.
    public typealias PlayerViewController = VerizonVideoPartnerSDK.PlayerViewController
    #endif
}
