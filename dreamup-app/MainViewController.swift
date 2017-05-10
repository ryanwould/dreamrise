//
//  MainViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/6/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI
import SideMenu
import AVFoundation
import NVActivityIndicatorView
import SnapKit


class MainViewController: UIViewController {
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    @IBOutlet weak var tableView: UITableView!
    
    //**************************************
    // MARK: - AVPlayer
    //**************************************
    var voiceMemos: [VoiceMemo]?
    var audioPlayer: AVAudioPlayer!
    var player: AVPlayer!
    var timeObserverToken: Any?
    var tappedCell: VoiceMemoCell!
    
    //**************************************
    // MARK: - Firebase
    //**************************************
    var usersRef: FIRDatabaseReference!
    var voiceMemosRef: FIRDatabaseReference!
    var dataSource: FUITableViewDataSource?
    
    // Logged in User
    var currentUser: FIRUser?
    
    // *************************************
    // Recorder View
    // *************************************
    
    @IBOutlet weak var recorderView: UIView!
    @IBOutlet weak var recordingIndicator: UIView!
    var recorderAnimationView: NVActivityIndicatorView?
    var recorderAnimating = false
    @IBOutlet weak var recordingButton: UIButton!
    
    @IBAction func recordButton(_ sender: Any) {
        if self.recorderAnimating {
            print("stopping recording")
            stopAnimatingRecorderView()
        } else {
            print("starting recording")
            startAnimatingRecorderView()
        }
    }
    
    func startAnimatingRecorderView(){
        //self.recorderView.frame = CGRect(x: self.recorderView.frame.minX, y: self.recorderView.frame.minY, width: self.recorderView.frame.width, height: self.recorderView.frame.height + 100)
        print("recorder height: \(self.recorderView.frame.height)")
        
        UIView.animate(withDuration: 1.0, animations: { Void in
            self.recorderView.frame.origin.y = self.recorderView.frame.origin.y + 100
            self.recorderView.layoutIfNeeded()
        })
        
        
        self.recorderAnimating = true
        let frame = self.recordingIndicator!.frame
        self.recorderAnimationView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballClipRotatePulse)
        self.recordingButton.setTitle("RECORDING", for: .normal)
        
        recorderView.addSubview(recorderAnimationView!)
        recorderAnimationView?.startAnimating()
    }
    
    func stopAnimatingRecorderView(){
        //self.recorderView.frame = CGRect(x: self.recorderView.frame.minX, y: self.recorderView.frame.minY, width: self.recorderView.frame.width, height: self.recorderView.frame.height - 100)
        print("recorder height: \(self.recorderView.frame.height)")
        
        UIView.animate(withDuration: 1.0, animations: { Void in
            self.recorderView.frame.origin.y = self.recorderView.frame.origin.y - 100
            self.recorderView.layoutIfNeeded()
        })
        
        recorderAnimationView?.stopAnimating()
        self.recordingButton.setTitle("TAP TO RECORD", for: .normal)
        self.recorderAnimating = false
    }

    // *************************************
    // Lifecycle methods
    // *************************************

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSideMenu()
        // Do any additional setup after loading the view.
        
        setupUI()
        createDatabaseRefs()
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Friend Cell")
        
        dataSource = FUITableViewDataSource.init(query: getQuery(), populateCell: {(tableView, indexPath, snapshot) in
            let value = snapshot.value as? [String: Any]
            let key = snapshot.key
            let cell = tableView.dequeueReusableCell(withIdentifier: "voice_memo_cell") as! VoiceMemoCell
            cell.backgroundColor = UIColor.clear
            
            let senderId = value?["sender"] as? String
            
            if let senderId = senderId {
                self.usersRef.child("\(senderId)").observe(.value, with: { (snap) in
                    let user = snap.value as? [String: Any]
                    let name = user?["name"] as? String
                    if let name = name {
                        cell.senderName.text = name
                    }
                })
            } else {
                print("SENDER ID: \(senderId)")
            }
            return cell
            
        })
        
        tableView.dataSource = dataSource
        tableView.delegate = self
        
        dataSource?.bind(to: tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
        
        // Enable gestures. The left and/or right menus must be set up above for these to work.
        // Note that these continue to work on the Navigation Controller independent of the View Controller it displays!
        SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)

    }
    
    func createDatabaseRefs() {
        self.usersRef = FIRDatabase.database().reference().child("users")
        self.currentUser = FIRAuth.auth()?.currentUser
        
        if let userId = currentUser?.uid {
            self.voiceMemosRef = FIRDatabase.database().reference().child("voice_memos/\(userId)")
        } else {
            print("unable to set voiceMemosRef")
        }
    }
    
    func setupUI(){
        self.tableView.backgroundColor = UIColor.black
    }
    
    // *************************************
    // MARK: - Table view data source
    // *************************************
    
    func getQuery() -> FIRDatabaseQuery {
        return (voiceMemosRef)
    }
    
    func playAudio(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        
        self.player = AVPlayer(playerItem:playerItem)
        player!.volume = 1.0
        player!.play()
        
        startAnimatingVoiceMemoCell()
        
        print("**** playback started - in theory ****")
        
//        var times = [NSValue]()
//        
//        let startTime = kCMTimeZero
//        let endTime = playerItem.duration
//        
//        times.append(NSValue(time: startTime))
//        times.append(NSValue(time: endTime))
//        let mainQueue = DispatchQueue.main
//        
//        self.timeObserverToken = player!.addBoundaryTimeObserver(forTimes: times, queue: mainQueue) { [weak self] time in
//            print("IN TIME OBSERVER \(time)")
//        }
        
//        print(self.timeObserverToken.debugDescription)
//        print(self.timeObserverToken.customMirror)
        
        //when player stalls
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerPlaybackStalled(note:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: self.player.currentItem)
        
        // Error log entry
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerErrorEntry(note:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: self.player.currentItem)
        
        //when player plays to end time
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player.currentItem)
        
        //when player does not finish playing
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidNotFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: self.player.currentItem)
        
    }
    
    func playerPlaybackStalled(note: NSNotification){
        print("PLAYBACK STALLED: \(note)")
    }
    
    func playerErrorEntry(note: NSNotification){
        print("PLAYER ERROR ENTRY: \(note)")
    }
    
    func playerDidNotFinishPlaying(note: NSNotification) {
        self.tappedCell.actionSubtext.text = "Failed to play. Try again"
    }
    
    func playerDidFinishPlaying(note: NSNotification) {
        stopAnimatingVoiceMemoCell()
    }
    
    func startAnimatingVoiceMemoCell(){
        
        // stop all other cells animating
        let cells = self.tableView.visibleCells
        for cell in cells {
            if let vmc = cell as? VoiceMemoCell {
                vmc.activityIndicatorView?.removeFromSuperview()
                vmc.actionSubtext.text = "tap to listen"
            }
        }
        
        if let cell = self.tappedCell {
            if cell.activityIndicator.isHidden {
                cell.activityIndicator.isHidden = false
            }
            let frame = cell.activityIndicator.frame
            cell.activityIndicatorView = NVActivityIndicatorView(frame: frame,
                                                                type: NVActivityIndicatorType.lineScalePulseOut)
            cell.addSubview(cell.activityIndicatorView!)
            cell.activityIndicatorView!.startAnimating()
            cell.actionSubtext.text = "playing..."
        }
        
    }
    
    func stopAnimatingVoiceMemoCell(){
        if let cell = self.tappedCell {
            cell.activityIndicatorView?.stopAnimating()
            cell.activityIndicatorView?.removeFromSuperview()
            cell.actionSubtext.text = "tap to listen"
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

extension MainViewController: UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = self.voiceMemos?.count {
            print("returning \(count)\n\n\n\n")
            return count
        } else {
            print("returning 0")
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("SELECTING ROW AT: \(indexPath.row) \nMemo: \(dataSource?.items[indexPath.row])")
        let value = dataSource?.items[indexPath.row].value as! [String: Any]
        let url: URL = URL(string: value["download_url"] as! String)!
        self.tappedCell = tableView.cellForRow(at: indexPath) as! VoiceMemoCell
        self.tappedCell.actionSubtext.text = "Playing..."
        playAudio(url: url)
    }

}
