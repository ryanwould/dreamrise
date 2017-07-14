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
    
    @IBOutlet weak var recordingIndicator: UIView!
    var recorderAnimationView: NVActivityIndicatorView?
    var recorderAnimating = false
    @IBOutlet weak var recordingButton: UIButton!
    
//    @IBAction func recordButton(_ sender: Any) {
//        if self.recorderAnimating {
//            print("stopping recording")
//            stopAnimatingRecorderView()
//        } else {
//            print("starting recording")
//            startAnimatingRecorderView()
//        }
//    }
//    
//    func startAnimatingRecorderView(){
//        //self.recorderView.frame = CGRect(x: self.recorderView.frame.minX, y: self.recorderView.frame.minY, width: self.recorderView.frame.width, height: self.recorderView.frame.height + 100)
//        print("recorder height: \(self.recorderView.frame.height)")
//        
//        UIView.animate(withDuration: 1.0, animations: { Void in
//            self.recorderView.frame.origin.y = self.recorderView.frame.origin.y + 100
//            self.recorderView.layoutIfNeeded()
//        })
//        
//        
//        self.recorderAnimating = true
//        let frame = self.recordingIndicator!.frame
//        self.recorderAnimationView = NVActivityIndicatorView(frame: frame, type: NVActivityIndicatorType.ballClipRotatePulse)
//        self.recordingButton.setTitle("RECORDING", for: .normal)
//        
//        recorderView.addSubview(recorderAnimationView!)
//        recorderAnimationView?.startAnimating()
//    }
//    
//    func stopAnimatingRecorderView(){
//        //self.recorderView.frame = CGRect(x: self.recorderView.frame.minX, y: self.recorderView.frame.minY, width: self.recorderView.frame.width, height: self.recorderView.frame.height - 100)
//        print("recorder height: \(self.recorderView.frame.height)")
//        
//        UIView.animate(withDuration: 1.0, animations: { Void in
//            self.recorderView.frame.origin.y = self.recorderView.frame.origin.y - 100
//            self.recorderView.layoutIfNeeded()
//        })
//        
//        recorderAnimationView?.stopAnimating()
//        self.recordingButton.setTitle("TAP TO RECORD", for: .normal)
//        self.recorderAnimating = false
//    }

    // *************************************
    // Lifecycle methods
    // *************************************

    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view.
        
        createDatabaseRefs(callback: { () -> Void in
            setDatasource()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = Colors().spaceCadet
        tableView.snp.makeConstraints { (make) -> Void in
            make.bottom.equalTo(self.view).offset(-75)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createDatabaseRefs(callback: () -> Void) {
        self.usersRef = FIRDatabase.database().reference().child("users")
        self.currentUser = FIRAuth.auth()?.currentUser
        
        if let userId = currentUser?.uid {
            self.voiceMemosRef = FIRDatabase.database().reference().child("voice_memos/\(userId)")
            callback()
        } else {
            print("unable to set voiceMemosRef")
        }
    }
    
    // *************************************
    // MARK: - Table view data source
    // *************************************
    
    func getQuery() -> FIRDatabaseQuery {
        return (voiceMemosRef)
    }
    
    func setDatasource(){
        self.tableView.reloadData();
        
        print("SETTING UP DATASOURCE")
        dataSource = FUITableViewDataSource.init(query: getQuery(), populateCell: {(tableView, indexPath, snapshot) in
            let value = snapshot.value as? [String: Any]
            let key = snapshot.key
            let cell = tableView.dequeueReusableCell(withIdentifier: "voice_memo_cell") as! VoiceMemoCell
            cell.backgroundColor = Colors().spaceCadet
            
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
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Friend Cell")
    }
    
    func playAudio(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        
        self.player = AVPlayer(playerItem: playerItem)
        player!.volume = 1.0
        player!.play()
        
        startAnimatingVoiceMemoCell()
        
        print("**** playback started - in theory ****")
        
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
