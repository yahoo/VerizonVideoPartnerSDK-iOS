//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit
import SafariServices

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
        func process(props: Player.Properties) {
            guard let item = props.playbackItem else { return }
            guard item.isClickThroughToggled, !isClickthroughActive else { return }
            
            if let creative = item.mp4AdCreative {
                isAdVPAID = false
                guard let url = creative.clickthrough else { return }
                showSafari(url, self)
            }
            if let creative = item.vpaidAdCreative {
                isAdVPAID = true
                guard let url = item.vpaidClickthrough ?? creative.clickthrough else { return safariFinishHandler(isAdVPAID) }
                showSafari(url, self)
            }
            isClickthroughActive = true
        }
    }
}

extension PlayerViewController.AdClickthroughWorker: SFSafariViewControllerDelegate {
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        isClickthroughActive = false
        safariFinishHandler(isAdVPAID)
    }
}
