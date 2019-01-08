//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.
import Foundation
import UIKit
import SafariServices

@available(iOS 9.0, *)
func openSafari(with url: URL, delegate: SFSafariViewControllerDelegate?) {
    let application = UIApplication.shared
    guard let viewController = application.keyWindow?.rootViewController else { return }
    let root = viewController.presentedViewController ?? viewController
    let safari = SFSafariViewController(url: url)
    safari.delegate = delegate
    root.present(safari,
                 animated: true,
                 completion: nil)
}
