//
//  AlarmInProgress.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/19/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import AVFoundation

class AlarmInProgress: UIViewController {
    
    @IBOutlet weak var alarmFireDateLabel: UILabel!
    var alarmFireTime: Date?
    let defaults = UserDefaultsManager()
    var avQueuePlayer: AVQueuePlayer?
    
    

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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // alarm queue
        buildAlarmQueue()
        
        // set timer to start alarm at alarmFireTime
        if alarmFireTime != nil {
            let timeUntilAlarm = alarmFireTime?.timeIntervalSinceNow
            print("INTERVAL: \(timeUntilAlarm)")
            
        }
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
    
    func buildAlarmQueue(){
        let queue = defaults.getAlarmQueue()
        print("\n\nALARM QUEUE:")
        
        var queueItems = [AVPlayerItem]()
        
        if let queue = queue {
            print("queue - \(queue.count)")
            for item in queue {
                print("item in queue - \(item)")
                let queueItem = defaults.getPlaySettingsForId(id: item) as? [String: Any]
                let urlString = queueItem?["url"] as? String
                
                guard urlString != nil else {
                    print("urlstring is nil")
                    break
                }
                
                let url = URL(string: urlString!)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
                
                guard url != nil else {
                    print("url is nil")
                    break
                }
                
                print("URL: \(url)")
                
                // Create asset to be played
                let asset = AVAsset(url: url!)
                
                let assetKeys = [
                    "playable",
                    "hasProtectedContent"
                ]
                
                // Create a new AVPlayerItem with the asset and an
                // array of asset keys to be automatically loaded
                let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
                
                queueItems.append(playerItem)
            }
        }
        self.avQueuePlayer = AVQueuePlayer.init(items: queueItems)
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
