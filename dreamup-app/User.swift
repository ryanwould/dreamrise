//
//  User.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 3/27/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import Foundation


class User: NSObject {
    var uid: String = ""
    var email: String = ""
    var username: String = ""
    var name: String = ""
    
    init(uid: String, name: String, email: String, username: String) {
        self.uid = uid;
        self.name = name;
        self.email = email;
        self.username = username;
        super.init()
    }
}

//class VoiceMemo: NSObject {
//    var uid: String
//    var downloadURL: String
//    var sender: String
//    var receivedDate: Date
//    var listened: Bool
//    var expirationDate: Date
//    
//    init(uid: String, downloadURL: String, sender: String, receivedDate: Date, listened: Bool, expirationDate: Date) {
//        self.uid = uid;
//        self.downloadURL = downloadURL;
//        self.sender = sender;
//        self.listened = listened;
//        self.receivedDate = receivedDate;
//        self.expirationDate = expirationDate;
//        super.init()
//    }
//}
