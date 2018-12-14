//  Copyright 2018, Oath Inc.
//  Licensed under the terms of the MIT License. See LICENSE.md file in project root for terms.

import UIKit


class TextCell: UITableViewCell {
    struct Props {
        let name: String
        let select: (UIViewController) -> ()
    }
    
    @IBOutlet weak private var nameLabel: UILabel!
    
    var props = Props(name: "", select: { _ in }) {
        didSet { layoutSubviews() }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        nameLabel.text = props.name
    }
}
