//
//  CommentTableViewCell.swift
//  Pokedex
//
//  Created by Infinum Student Academy on 29/07/2017.
//  Copyright © 2017 Ivan Ilic. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(_ username: String, _ comment: String) {
        usernameLabel.text = username
        commentLabel.text = comment
    }

}
