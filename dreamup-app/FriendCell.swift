//
//  FriendCell.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 3/27/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class FriendCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet var indicator: SelectedIndicator!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
