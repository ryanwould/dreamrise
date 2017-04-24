//
//  Podcast.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import Foundation
import MediaPlayer

class Podcast: NSObject {
    
    var podcastTitle: String
    var episodeTitle: String
    var author: String
    var duration: TimeInterval
    var image: MPMediaItemArtwork?
    var assetUrl: URL?
    
    init(podcastTitle: String, episodeTitle: String, author: String, duration: TimeInterval, image: MPMediaItemArtwork?, assetUrl: URL?) {
        self.podcastTitle = podcastTitle
        self.episodeTitle = episodeTitle
        self.author = author
        self.duration = duration
        self.image = image
        self.assetUrl = assetUrl
    }
    
    class func parseMediaItem(mediaItem: MPMediaItem) -> (Podcast) {
        let podTitle = mediaItem.podcastTitle ?? ""
        let epTitle = mediaItem.title ?? ""
        let author = mediaItem.artist ?? ""
        let duration = mediaItem.playbackDuration
        let image = mediaItem.artwork
        let assetUrl = mediaItem.assetURL
        
        
        let podcast = Podcast(podcastTitle: podTitle, episodeTitle: epTitle, author: author, duration: duration, image: image, assetUrl: assetUrl)
        return podcast
    }
}
