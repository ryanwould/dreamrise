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
    var queueCount: Int = 0
    
    // MARK: - OUTLETS
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var podcastTitleLabel: UILabel!
    @IBOutlet weak var moonImage: UIImageView!
    
    // MARK: - ACTIONS
    
    @IBAction func didCancelAlarm(_ sender: Any) {
        // undo setup
        undoViewSetup()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        guard avQueuePlayer != nil else { return }
        
        if (avQueuePlayer!.isPlaying) {
            avQueuePlayer!.pause()
            btnPlay.setTitle("play", for: .normal)
        } else {
            btnPlay.setTitle("pause", for: .normal)
            avQueuePlayer!.play()
        }
    }
    
    
    func pause(){
        guard avQueuePlayer != nil else { return }
        
        if (avQueuePlayer!.isPlaying) {
            avQueuePlayer!.pause()
            btnPlay.setTitle("play", for: .normal)
        }
    }
    
    func play() {
        guard avQueuePlayer != nil else { return }
        
        if (!avQueuePlayer!.isPlaying) {
            avQueuePlayer!.play()
            btnPlay.setTitle("pause", for: .normal)
        }
    }
    
    @IBAction func actNext(_ sender: Any) {
        
        // decrement Queue Count
        self.queueCount -= 1
        
        guard avQueuePlayer != nil else { return }
        let itemsLeft = self.queueCount
        
        if (itemsLeft > 0) {
            avQueuePlayer!.advanceToNextItem()
            
            //increment current item index
            currentItemIndex += 1
            podcastTitleLabel.text = podcastTitles?[currentItemIndex]
        } else {
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //stop alarm
        self.avQueuePlayer = nil
        self.alarmFireTime = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //add observer to Audio Route (headphones unplugged, etc.
        setupNotifications()
        
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
    
    // MARK: - NOTIFICATION CENTER
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRouteChange),
                                               name: .AVAudioSessionRouteChange,
                                               object: AVAudioSession.sharedInstance())
    }
    
    func removeNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleRouteChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
            let reasonValue = userInfo[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let reason = AVAudioSessionRouteChangeReason(rawValue:reasonValue) else {
                print("RETURNING")
                return
        }
        switch reason {
        case .newDeviceAvailable:
            // Handle new device available.
            // Play audio through new device
            print("NEW DEVICE AVAILABLE")
            play()
        case .oldDeviceUnavailable:
            // Handle old device removed.
            //
            print("OLD DEVICE REMOVED")
            pause()
        default: ()
        }
    }
    
    // MARK: - ALARM
    
    func soundTheAlarm(){
        print("playing alarm")
        
        //show audio control buttons
        showAudioButtons()
        
        // ***********************
        // USING AVQUEUEPLAYER
        // ***********************
        
        if let player = avQueuePlayer {
            player.volume = 1.0
            player.play()
            
            do {
                // Set to play through speakers even if phone is silent
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch let error as NSError {
                print("There was an error: \(error)")
            }
            
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
        // hide audio buttons
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
    
    func setGradient(){
        // Set gradient
        let gradient: CAGradientLayer = CAGradientLayer()
        
        gradient.colors = [Colors().darkBlue.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.05 , 0.95]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        gradient.frame = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        
        self.view.layer.insertSublayer(gradient, at: 0)
        
    }
    
    func undoViewSetup(){
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
        
        //add observer to Audio Route (headphones unplugged, etc.
        removeNotifications()
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
        
        alarmItems = []
        podcastTitles = []
        
        if let queue = queue {
            itemloop: for item in queue {
                
                let queueItem = defaults.getPlaySettingsForId(id: item)
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
                    }
                }
            }
        }
        // init AVQueuePlayer
        if let alarmItems = alarmItems {
            avQueuePlayer = AVQueuePlayer.init(items: alarmItems)
            print("initialized queue player with \(alarmItems.count)")
            
            // set Queue Count
            self.queueCount = alarmItems.count
        }
    }
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
extension UIView {
    func rotateImageNonstop(_ duration: CFTimeInterval = 10, completionDelegate: AnyObject? = nil) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(M_PI)
        rotateAnimation.duration = duration
        
        if let delegate: AnyObject = completionDelegate {
            rotateAnimation.delegate = delegate as! CAAnimationDelegate
        }
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
