//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit


class TutorialsViewController: UITableViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        guard let tutorialCasesViewController = segue.destination as? TutorialCasesViewController else { fatalError("Unknown segue destination") }
        
        switch identifier {
        case "PlayingVideos": setupPlayingVideos(tutorialCasesViewController: tutorialCasesViewController)
        case "CustomUX": setupCustomUX(tutorialCasesViewController: tutorialCasesViewController)
        case "Observing": setupObserving(tutorialCasesViewController: tutorialCasesViewController)
        case "ErrorHandling": setupErrorHandling(tutorialCasesViewController: tutorialCasesViewController)
        default: break
        }
    }
}

