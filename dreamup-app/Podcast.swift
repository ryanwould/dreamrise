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
    var podcastDescription: String
    
    init(podcastTitle: String,
         episodeTitle: String,
         author: String,
         duration: TimeInterval,
         image: MPMediaItemArtwork?,
         assetUrl: URL?,
         podcastDescription: String
        )
    {
        self.podcastTitle = podcastTitle
        self.episodeTitle = episodeTitle
        self.author = author
        self.duration = duration
        self.image = image
        self.assetUrl = assetUrl
        self.podcastDescription = podcastDescription
    }
    
    class func parseMediaItem(mediaItem: MPMediaItem) -> (Podcast) {
        let podTitle = mediaItem.podcastTitle ?? ""
        let epTitle = mediaItem.title ?? ""
        let author = mediaItem.artist ?? ""
        let duration = mediaItem.playbackDuration
        let image = mediaItem.artwork
        let assetUrl = mediaItem.assetURL
        let podcastDescription = mediaItem.comments ?? ""
        
        
        let podcast = Podcast(podcastTitle: podTitle,
                              episodeTitle: epTitle,
                              author: author,
                              duration: duration,
                              image: image,
                              assetUrl: assetUrl,
                              podcastDescription: podcastDescription)
        return podcast
    }
    
    func debug(){
        print("---\nPodcast:\n\(self.episodeTitle)")
        print("title:       \(self.podcastTitle)")
        print("author:      \(self.author)")
        print("duration:    \(self.duration)")
        print("url:         \(self.assetUrl)")
        print("description: \(self.podcastDescription)")
    }
}
