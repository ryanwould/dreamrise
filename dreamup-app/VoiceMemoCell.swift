//
//  VoiceMemoCellTableViewCell.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/16/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class VoiceMemoCell: UITableViewCell {

    @IBOutlet weak var senderName: UILabel!
    @IBOutlet weak var actionSubtext: UILabel!
    @IBOutlet weak var activityIndicator: UIView!
    
    var activityIndicatorView: NVActivityIndicatorView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
