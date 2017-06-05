//
//  RecipientBarView.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/1/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RecipientBarView: UIView {
    
    
    @IBOutlet weak var animationPlaceholder: UIView!
    var animationView: NVActivityIndicatorView?
    
    @IBOutlet weak var recipientsLabel: UILabel!
    @IBOutlet weak var sendButton: UIButton!
    var parentView: SendAudioTableViewController?
    
    class func instanceFromNib() -> RecipientBarView {
        return UINib(nibName: "RecipientBarView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! RecipientBarView
    }
    
    @IBAction func sendButton(_ sender: Any) {
        self.parentView?.sendAudio()
        self.recipientsLabel.text = "Sending..."
        self.sendButton.isHidden = true
        
        // create loading indicator
        let animation = NVActivityIndicatorView(frame: animationPlaceholder.frame, type: NVActivityIndicatorType.ballClipRotatePulse)
        animation.startAnimating()
        self.addSubview(animation)
        self.animationView = animation
    }

}
