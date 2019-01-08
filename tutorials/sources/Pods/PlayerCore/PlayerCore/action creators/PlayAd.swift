//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import Foundation

public func playAd(model: Ad.VASTModel, id: UUID, isOpenMeasurementEnabled: Bool) -> Action {
    let adCreative: AdCreative? = {
        if let mp4MediaFile = model.mediaFiles.first(where: { $0.type == .mp4 }) {
            return AdCreative.mp4(
                .init(
                    url: mp4MediaFile.url,
                    clickthrough: model.clickthrough,
                    pixels: model.pixels,
                    id: model.id,
                    scalable: mp4MediaFile.scalable,
                    maintainAspectRatio: mp4MediaFile.maintainAspectRatio))
        }
        if let vpaidMediaFile = model.mediaFiles.first(where: { $0.type == .vpaid }) {
            return AdCreative.vpaid(
                .init(
                    url: vpaidMediaFile.url,
                    adParameters: model.adParameters,
                    clickthrough: model.clickthrough,
                    pixels: model.pixels,
                    id: model.id))
        }
        return nil
    }()
    guard let creative = adCreative else { return SkipAd(id: id) }
    return ShowAd(creative: creative,
                  id: id,
                  adVerifications: model.adVerifications,
                  isOpenMeasurementEnabled: isOpenMeasurementEnabled)
}

