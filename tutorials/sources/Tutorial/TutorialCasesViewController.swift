//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit


class TutorialCasesViewController: UITableViewController {
    struct Props {
        var rows: [TextCell.Props] = []
    }
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    var props: Props = Props() {
        didSet {
            guard isViewLoaded else { return }
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "PlayerWrapper" else { return }
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        props.rows[indexPath.row].select(segue.destination)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return props.rows.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell") as? TextCell else {
            fatalError("Unknown cell")
        }
        cell.props = props.rows[indexPath.row]
        return cell
    }
}
