//
//  AlarmInProgress.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/19/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

struct AlarmQueueItem {
    var playerItem: AVPlayerItem
    var duration: Int
}

class AlarmInProgress: UIViewController {
    
    @IBOutlet weak var alarmFireDateLabel: UILabel!
    var alarmFireTime: Date?
    let defaults = UserDefaultsManager()
    var avQueuePlayer: AVQueuePlayer?
    var timer = Timer()
    var alarmItems: [AlarmQueueItem]?
    var player: AVPlayer!
    
    

    @IBAction func didCancelAlarm(_ sender: Any) {
        // undo setup
        undoViewSetup()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup
        setupView()
        
        //alarm
        guard alarmFireTime != nil else {
            print("alarm not set"); return
        }
        print(alarmFireTime!)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //stop alarm
        self.avQueuePlayer = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alarm queue
        buildAlarmQueue()
        
        // set timer to start alarm at alarmFireTime
        if alarmFireTime != nil {
            let timeUntilAlarm = alarmFireTime?.timeIntervalSinceNow
            print("INTERVAL: \(timeUntilAlarm)")
        
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.soundTheAlarm), userInfo: nil, repeats: false)
            
//            timer = Timer(fireAt: Date().addingTimeInterval(5.0),
//                          interval: 0.0,
//                          target: self,
//                          selector: #selector(soundTheAlarm),
//                          userInfo: nil, repeats: false)
        }
    }
    
    func soundTheAlarm(){
        print("playing alarm")
        do {
            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch _ {
            print("error setting AVAudioSessionPortOverride")
        }
        
        // ***********************
        // USING AVPLAYER
        // ***********************
        
        if let items = alarmItems {
            
            print("ITEMS: \(items.count)")
            
            for item in items {
                self.player = AVPlayer(playerItem: item.playerItem)
                print("PLAYER: \(self.player)")
                let nsDuration = item.duration as NSValue
                player.addBoundaryTimeObserver(forTimes: [nsDuration], queue: DispatchQueue.main, using: { Void in
                    print("TIMES UP!")
                })
                player.volume = 1.0
                player.play()
            }
        }
        
        // ***********************
        // USING AVQUEUEPLAYER
        // ***********************
        
        //        if let player = avQueuePlayer {
        //            player.volume = 1.0
        //            player.play()
        //            print("current item: \(player.currentItem)")
        //        } else {
        //            print("player is nil")
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){
        self.view.backgroundColor = Colors().darkBlue
        
        // Hide the status bar
        UIApplication.shared.isStatusBarHidden = true
        
        // Disable screen going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // set alarm fire date label
        guard alarmFireTime != nil else {
            return
        }
        formatAlarmTime(time: alarmFireTime!)
        
    }
    
    func undoViewSetup(){
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func formatAlarmTime(time: Date) {
        let localTimeZone = TimeZone.current.identifier
        let f = DateFormatter()
        f.locale = Locale(identifier: localTimeZone)
        f.dateFormat = "h:mm a"
        alarmFireDateLabel.text = f.string(from: time)
    }
    
    func buildAlarmQueue() {
        let queue = defaults.getAlarmQueue()
        print("\n\nALARM QUEUE:")
        
        avQueuePlayer = AVQueuePlayer()
        alarmItems = []
        
        if let queue = queue {
            print("queue - \(queue.count)")
            itemloop: for item in queue {
                
                let queueItem = defaults.getPlaySettingsForId(id: item)
                print("CURRENT ITEM: - \(queueItem.debugDescription)")
                
                let urlString = queueItem["url"] as? String
                let durationString = queueItem["duration"] as? String
                
                if let duration = durationString {
                    if let intDuration = Int(duration) {
                        
                        //check urlstring
                        guard urlString != nil else {
                            print("urlstring is nil\n"); continue itemloop
                        }
                        
                        let url = URL(string: urlString!)
                        guard url != nil else { print("url is nil"); break }
                        
                        //create AVPlayerItem
                        let playerItem = AVPlayerItem(url: url!)
                        let alarmQueueItem = AlarmQueueItem(playerItem: playerItem, duration: intDuration)
                        
                        alarmItems?.append(alarmQueueItem)
                        //avQueuePlayer?.insert(playerItem, after: nil)
                    }
                }
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
