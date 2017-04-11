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
    var active: Bool = false
    
    var userId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.setInactive()
    }
    
    func toggleStatus() {
        self.active = !self.active
        
        if self.active == true {
            setActive()
        } else {
            setInactive()
        }
    }
    
    func setActive(){
        self.indicator.backgroundColor = UIColor(red: 66/255, green: 167/255, blue: 244/255, alpha: 0.8)
        self.indicator.layer.borderWidth = 0
    }
    
    func setInactive(){
        self.indicator.backgroundColor = UIColor.clear
        self.indicator.layer.borderWidth = 1
        self.indicator.layer.cornerRadius = 4
        self.indicator.layer.borderColor = UIColor.lightGray.cgColor

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
       
       
        // Configure the view for the selected state
        
    }

}
