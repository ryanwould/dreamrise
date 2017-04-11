//
//  RecipientBarView.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/1/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class RecipientBarView: UIView {

    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet weak var recipients: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    var parentView: SendAudioTableViewController?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    class func instanceFromNib() -> RecipientBarView {
        return UINib(nibName: "RecipientBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RecipientBarView
    }
    
    @IBAction func sendButton(_ sender: Any) {
        print(self.parentView ?? "no parentview")
        self.parentView?.sendAudio()
    }

}
