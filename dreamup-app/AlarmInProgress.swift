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
import MediaPlayer

struct AlarmQueueItem {
    var playerItem: AVPlayerItem
    var duration: Int
}

class AlarmInProgress: UIViewController {
    
    // Time Labels
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var alarmTimeLabel: UILabel!
    
    var alarmFireTime: Date?
    var currentTime = Date()
    let defaults = UserDefaultsManager()
    
    // Audio
    var avQueuePlayer: AVQueuePlayer?
    var timer = Timer()
    var alarmItems: [AVPlayerItem]?
    var podcastTitles: [String]?
    var currentItemIndex = 0
    var player: AVPlayer!
    
    // MARK: - OUTLETS
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var podcastTitleLabel: UILabel!
    
    // MARK: - ACTIONS
    
    @IBAction func didCancelAlarm(_ sender: Any) {
        // undo setup
        undoViewSetup()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actPlayPause(_ sender: Any) {
        guard avQueuePlayer != nil else { return }
        
        if (avQueuePlayer!.isPlaying) {
            avQueuePlayer!.pause()
            btnPlay.setTitle("play", for: .normal)
        } else {
            btnPlay.setTitle("pause", for: .normal)
            avQueuePlayer!.play()
        }
    }
    
    @IBAction func actNext(_ sender: Any) {
        
        guard avQueuePlayer != nil else { return }
        let itemsLeft = avQueuePlayer!.items().count
        if (itemsLeft > 0) {
            
            print("ITEMS LEFT IN QUEUE: \(itemsLeft)")
            avQueuePlayer!.advanceToNextItem()
            print("ITEMS LEFT IN QUEUE: \(itemsLeft)")
            
            //increment current item index
            currentItemIndex += 1
            podcastTitleLabel.text = podcastTitles?[currentItemIndex]
        } else {
            print("no items!")
            currentItemIndex = 0
            
            //close the alarm window
            undoViewSetup()
            dismiss(animated: true, completion: nil)
        }
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
        self.alarmFireTime = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIEW DID LOAD")
        
        // alarm queue
        buildAlarmQueue()
        
        if alarmFireTime != nil {
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {(timer) in
                self.checkTime()
            })
            
        }
    }
    
    // MARK: - Alarm
    
    func checkTime(){
        
        self.currentTime = Date()
        
        // update current time label
        currentTimeLabel.text = formatAlarmTime(time: Date(), seconds: false)
        
        // sound the alarm! (if its time)
        guard alarmFireTime != nil else {
            print("alarmFireTime is nil");
            print("canceling timer")
            self.timer.invalidate()
            return
            
        }
        
        print(
            "\n\n---\n" +
                "Current time: \(formatAlarmTime(time: currentTime, seconds: true))\n" +
            "  Alarm time: \(formatAlarmTime(time: alarmFireTime!, seconds: true))\n"
        )
        
        if Date() >= alarmFireTime! {
            soundTheAlarm()
            self.timer.invalidate()
            print(timer)
        }
    }
    
    func styleButtons() {
        let buttons = [btnPlay, btnNext]
        
        for btn in buttons {
            btn!.layer.cornerRadius = 0
            btn!.layer.borderWidth = 3
            btn!.layer.borderColor = UIColor.white.cgColor
        }
    }
    
    func showAudioButtons(){
        styleButtons()
        btnPlay.isHidden = false
        btnNext.isHidden = false
        
        // labels
        podcastTitleLabel.isHidden = false
        podcastTitleLabel.text = podcastTitles?[0]
    }
    
    func hideAudioButtons(){
        btnPlay.isHidden = true
        btnNext.isHidden = true
        
        //labels
        podcastTitleLabel.isHidden = true
    }
    
    func soundTheAlarm(){
        print("playing alarm")
//        do {
//            try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
//        } catch _ {
//            print("error setting AVAudioSessionPortOverride")
//        }
        
        //show audio control buttons
        showAudioButtons()
        
        // ***********************
        // USING AVQUEUEPLAYER
        // ***********************
        
        if let player = avQueuePlayer {
            player.volume = 1.0
            player.play()
            
            print("current item: \(player.currentItem)")
            let currentItem = player.currentItem
            
            if let currentItem = currentItem {
                podcastTitleLabel.text = podcastTitles?[0]
            }
        } else {
            print("player is nil")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){
        self.view.backgroundColor = Colors().darkBlue
        
        hideAudioButtons()
        
        // Hide the status bar
        UIApplication.shared.isStatusBarHidden = true
        
        // Disable screen going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // set alarm fire date label
        guard alarmFireTime != nil else {
            return
        }
        alarmTimeLabel.text = formatAlarmTime(time: alarmFireTime!, seconds: false)
        currentTimeLabel.text = formatAlarmTime(time: currentTime, seconds: false)
        
    }
    
    func undoViewSetup(){
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func formatAlarmTime(time: Date, seconds: Bool) -> String {
        let localTimeZone = TimeZone.current.identifier
        let f = DateFormatter()
        f.locale = Locale(identifier: localTimeZone)
        
        if seconds { f.dateFormat = "h:mm:ss a" } else { f.dateFormat = "h:mm a" }
        return f.string(from: time)
    }
    
    func buildAlarmQueue() {
        let queue = defaults.getAlarmQueue()
        print("\n\nALARM QUEUE:")
        
        alarmItems = []
        podcastTitles = []
        
        if let queue = queue {
            print("queue - \(queue.count)")
            itemloop: for item in queue {
                
                let queueItem = defaults.getPlaySettingsForId(id: item)
                print("CURRENT ITEM: - \( queueItem["displayString"])")
                
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
                        
                        alarmItems?.append(playerItem)
                        podcastTitles?.append(queueItem["displayString"] as? String ?? "Podcast")
                        //avQueuePlayer?.insert(playerItem, after: nil)
                    }
                }
            }
        }
        // init AVQueuePlayer
        if let alarmItems = alarmItems {
            avQueuePlayer = AVQueuePlayer.init(items: alarmItems)
            print("initialized queue player with \(alarmItems.count)")
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

extension AVPlayer {
    
    var isPlaying: Bool {
        if (self.rate != 0 && self.error == nil) {
            return true
        } else {
            return false
        }
    }
    
}
