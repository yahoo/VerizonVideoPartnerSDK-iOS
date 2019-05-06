//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit
import SafariServices
import PlayerCore

extension PlayerViewController {
    final class AdClickthroughWorker: NSObject {
        let showSafari: (URL, SFSafariViewControllerDelegate) -> Void
        let safariFinishHandler: (Bool) -> Void
        
        init(showSafari: @escaping (URL, SFSafariViewControllerDelegate) -> Void,
             safariFinishHandler: @escaping (Bool) -> Void) {
            self.showSafari = showSafari
            self.safariFinishHandler = safariFinishHandler
        }
        
        var isClickthroughActive = false
        var isAdVPAID = false
        
        func process(isClickThroughToggled: Bool,
                     vpaidClickThroughURL: URL?,
                     mp4AdCreative: PlayerCore.AdCreative.MP4?,
                     vpaidAdCreative: PlayerCore.AdCreative.VPAID?) {
            guard isClickThroughToggled, !isClickthroughActive else { return }
            
            if let creative = mp4AdCreative {
                isAdVPAID = false
                guard let url = creative.clickthrough else { return }
                showSafari(url, self)
            }
            if let creative = vpaidAdCreative {
                isAdVPAID = true
                guard let url = vpaidClickThroughURL ?? creative.clickthrough else { return safariFinishHandler(isAdVPAID) }
                showSafari(url, self)
            }
            isClickthroughActive = true
        }
        
        func process(props: Player.Properties) {
            guard let item = props.playbackItem else { return }
            process(isClickThroughToggled: item.isClickThroughToggled,
                    vpaidClickThroughURL: item.vpaidClickthrough,
                    mp4AdCreative: item.mp4AdCreative,
                    vpaidAdCreative: item.vpaidAdCreative)
        }
    }
}

extension PlayerViewController.AdClickthroughWorker: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        isClickthroughActive = false
        safariFinishHandler(isAdVPAID)
    }
}
