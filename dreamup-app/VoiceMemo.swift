//
//  VoiceMemo.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/6/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import Firebase
import Foundation

class VoiceMemo: NSObject {
    var downloadUrl : String
    var expiresAt   : Double
    var listenedAt  : Double?
    var playCount   : Int
    var saved       : Bool
    var senderId    : String
    var senderName  : String
    var sentAt      : Double
    
    init(downloadUrl: String,
         expiresAt: Double,
         listenedAt: Double?,
         playCount: Int,
         saved: Bool,
         senderId: String,
         senderName: String,
         sentAt: Double)
    {
        self.downloadUrl = downloadUrl
        self.expiresAt = expiresAt
        self.listenedAt = listenedAt
        self.playCount = playCount
        self.saved = saved
        self.senderId = senderId
        self.senderName = senderName
        self.sentAt = sentAt
    }
}
