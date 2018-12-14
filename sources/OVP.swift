//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation

/// Enum with typealiases available globally.
// swiftlint:disable type_name
public enum OVP {
    /// SDK shorthand.
    public typealias SDK = OathVideoPartnerSDK.OVPSDK
    /// Player shorthand.
    public typealias Player = OathVideoPartnerSDK.Player
    /// Content Video Playback Events shorthand.
    public typealias PlaybackEvents = OathVideoPartnerSDK.PlaybackEvents
    
    #if os(iOS)
    /// Player View Controller shorthand.
    public typealias PlayerViewController = OathVideoPartnerSDK.PlayerViewController
    #endif
}
