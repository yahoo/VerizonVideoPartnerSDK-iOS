//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import VerizonVideoPartnerSDK

func singleVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "577cc23d50954952cc56bc47") }
}

#if os(iOS)
func arrayOfVideos() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoIDs: ["593967be9e45105fa1b5939a",
                                        "577cc23d50954952cc56bc47",
                                        "5939698f85eb427b86aa0a14"]) }
}

func videoPlaylist() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(playlistID: "577cc27b88d2ff0d0f5acc71") }
}
#endif

func mutedVideo() -> Future<Result<Player>> {
    func mute(player: inout Player) { player.mute() }
    return singleVideo().map(mute)
}

func videoWithoutAutoplay() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "577cc23d50954952cc56bc47",
                             autoplay: false) }
}

func liveVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5a600ab092fdde68e1f7a606") }
}

func subtitlesVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "59397934955a316f1c4f65b4") }
}

func restrictedVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "59396b1c9e45105fa1b599c9") }
}

func deletedVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "577cc23d50954952cc56bc48") }
}

func unknownVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "unknown") }
}
