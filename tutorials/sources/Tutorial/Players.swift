//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation
import VerizonVideoPartnerSDK

func singleVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5be162270822e865c05571da") }
}

#if os(iOS)
func arrayOfVideos() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoIDs: ["5be157906614d143c1eeb5ae",
                                        "5be15940007d0c759d8aa06b",
                                        "5be04fe9bf48852d05888487"]) }
}

func videoPlaylist() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(playlistID: "5be16352cf9d31000187830f") }
}
#endif

func mutedVideo() -> Future<Result<Player>> {
    func mute(player: inout Player) { player.mute() }
    return singleVideo().map(mute)
}

func videoWithoutAutoplay() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5be162270822e865c05571da",
                             autoplay: false) }
}

func liveVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5be06b6bc2ec100eee0af751") }
}

func subtitlesVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5be16478023e752a7573f1f4") }
}

func restrictedVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "5be15c63c2ec100eee0b6e3b") }
}

func deletedVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "666666666666666666666666") }
}

func unknownVideo() -> Future<Result<Player>> {
    return VVPSDK.Provider.default.getSDK()
        .then { $0.getPlayer(videoID: "unknown") }
}
