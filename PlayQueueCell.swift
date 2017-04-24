//
//  PlayQueueCell.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/5/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class PlayQueueCell: UITableViewCell {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var displayStringLabel: UILabel!
    @IBOutlet weak var displayMediaTypeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureIcon(){
        switch displayMediaTypeLabel.text! {
        case "radio":
            icon.image = UIImage(named: "radio")
        case "podcast":
            icon.image = UIImage(named: "mic")
        case "playlist":
            icon.image = UIImage(named: "playlist")
        default:
            icon.image = UIImage(named: "music")
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
