//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public func showMP4Ad(creative: AdCreative.MP4, id: UUID) -> Action {
    return ShowMP4Ad(creative: creative, id: id)
}
public func showVPAIDAd(creative: AdCreative.VPAID, id: UUID) -> Action {
    return ShowVPAIDAd(creative: creative, id: id)
}

public func playAd(model: Ad.VASTModel, id: UUID) -> Action {
    let adCreative: AdCreative? = {
        if let mediaFile = model.mp4MediaFiles.first {
            return AdCreative.mp4(
                [.init(
                    url: mediaFile.url,
                    clickthrough: model.clickthrough,
                    pixels: model.pixels,
                    id: model.id,
                    width: mediaFile.width,
                    height: mediaFile.height,
                    scalable: mediaFile.scalable,
                    maintainAspectRatio: mediaFile.maintainAspectRatio)])
        }
        if let mediaFile = model.vpaidMediaFiles.first {
            return AdCreative.vpaid(
                [.init(
                    url: mediaFile.url,
                    adParameters: model.adParameters,
                    clickthrough: model.clickthrough,
                    pixels: model.pixels,
                    id: model.id)])
        }
        return nil
    }()
    guard let creative = adCreative else { return DropAd(id: id) }
    return ShowAd(creative: creative,
                  id: id,
                  adVerifications: model.adVerifications)
}
