//
//  RadioTableViewCell.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class RadioTableViewCell: UITableViewCell {

    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var stationDescLabel: UILabel!
    @IBOutlet weak var stationImageView: UIImageView!
    var streamUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureStationCell(station: RadioStation) {
        
        // Configure the cell...
        stationNameLabel.text = station.stationName
        stationDescLabel.text = station.stationDesc
        streamUrl = station.stationStreamURL
        
        // let imageURL = station.stationImageURL as NSString
        
//        if imageURL.contains("http") {
//            
//            if let url = URL(string: station.stationImageURL) {
//                downloadTask = stationImageView.loadImageWithURL(url: url) { (image) in
//                    // station image loaded
//                }
//            }
//            
//        } else if imageURL != "" {
//            stationImageView.image = UIImage(named: imageURL as String)
//            
//        } else {
//            stationImageView.image = UIImage(named: "stationImage")
//        }
//        
//        stationImageView.applyShadow()
    }


}
