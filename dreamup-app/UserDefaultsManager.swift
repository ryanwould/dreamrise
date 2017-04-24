//
//  UserDefaultsManager.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import Foundation

protocol UserDefaultsProtocol {
    func createRadioAlarmItem(stationTitle: String, streamUrl: String)
    
    func getAlarmQueue() -> [String]?
    func setAlarmQueue(data: [String]) -> Void
    func appendToAlarmQueue(id: String) -> Void
    func getPlaySettingsForId(id: String) -> [String: Any]
    func setPlaySettingsForId(id: String, settings: [String: Any]) -> Void
    func deletePlaySettingsForId(id: String) -> Void
    
    
    func setCurrentAlarm(time: NSDate) -> Void
}

//**********************************************
// Helper class to get values from UserDefaults
//**********************************************

class UserDefaultsManager: UserDefaultsProtocol {
    
    func appendToAlarmQueue(id: String) {
        guard var newQueue = getAlarmQueue() else {
            print("nothing in alarm queue")
            print(getAlarmQueue() as Any)
            //if nothing in queue
            setAlarmQueue(data: [id])
            return
        }
        newQueue.append(id)
        setAlarmQueue(data: newQueue)
        print(getAlarmQueue() as Any)
    }

    //TODO: change to take a radio station object
    func createRadioAlarmItem(stationTitle: String, streamUrl: String) {
        let id = String(Int(Date().timeIntervalSince1970))
        let settings: [String: Any] = [
            "duration": "300",
            "stationTitle": stationTitle,
            "streamUrl": streamUrl,
            "displayString": stationTitle,
            "mediaType": "radio",
        ]
        //create play settings
        setPlaySettingsForId(id: id, settings: settings)
        
        //append to alarm queue
        appendToAlarmQueue(id: id)
    }
    
    func createPodcastAlarmItem(podcast: Podcast) {
        let id = String(Int(Date().timeIntervalSince1970))
        guard let assetUrl = podcast.assetUrl else {
            print("bad url")
            return
        }
        let settings: [String: Any] = [
            "duration": String(Int(podcast.duration)),
            "episodeTitle": String(podcast.episodeTitle),
            "podcastTitle": String(podcast.podcastTitle),
            "assetUrl": String(describing: assetUrl),
            "displayString": String(podcast.episodeTitle),
            "mediaType": "podcast",
            ]
        //create play settings
        setPlaySettingsForId(id: id, settings: settings)
        
        //append to alarm queue
        appendToAlarmQueue(id: id)
    }
    //******************************************
    // MARK: - Current Alarm
    //******************************************
    
    func setCurrentAlarm(time: NSDate) {
        let alarm = [
            "setAt": Date(),
            "forTime": time,
            "isPlaying": false,
        ] as [String : Any]
        UserDefaults.standard.set(alarm, forKey: "currentAlarm")
    }
    
    func removeCurrentAlarm(id: String) {
        UserDefaults.standard.removeObject(forKey: "currentAlarm")
    }
    
    //******************************************
    // MARK: Getters and Setters
    //******************************************
    
    func getAlarmQueue() -> [String]? {
        return UserDefaults.standard.object(forKey: "alarmOrder") as? [String]
    }
    
    func setAlarmQueue(data: [String]) -> Void {
        UserDefaults.standard.set(data, forKey: "alarmOrder")
    }
    
    func getPlaySettingsForId(id: String) -> [String: Any] {
        return UserDefaults.standard.value(forKey: id) as! [String: Any]
    }
    
    func setPlaySettingsForId(id: String, settings: [String: Any]) -> Void {
        UserDefaults.standard.set(settings, forKey: id)
    }
    
    func deletePlaySettingsForId(id: String) {
        UserDefaults.standard.removeObject(forKey: id)
    }
}
