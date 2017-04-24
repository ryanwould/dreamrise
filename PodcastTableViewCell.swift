//
//  PodcastTableViewCell.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class PodcastTableViewCell: UITableViewCell {

    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var podcastImage: UIImageView!
    var assetUrl: URL?
    var podcast: Podcast?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configurePodcastCell(podcast: Podcast) {
        self.podcast = podcast
        title.text = podcast.podcastTitle
        episodeTitle.text = podcast.episodeTitle
        podcastImage.image = podcast.image?.image(at: CGSize(width: 60, height: 60))
        durationLabel.text = stringFromTimeInterval(interval: podcast.duration)
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }

}
