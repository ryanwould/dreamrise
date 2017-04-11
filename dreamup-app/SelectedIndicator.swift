//
//  SelectedIndicator.swift
//  
//
//  Created by Razgaitis, Paul on 3/27/17.
//
//

import UIKit

class SelectedIndicator: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    var selected: Bool = false
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func select(){
        if self.selected {
            self.selected = false
            self.backgroundColor = UIColor.clear
        } else {
            self.selected = true
            self.backgroundColor = UIColor.blue
        }
    }
}
