//
//  VoiceMemosTableViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/13/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabaseUI
import SideMenu
import AVFoundation
import NVActivityIndicatorView

class VoiceMemosTableViewController: UITableViewController {
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}

    var voiceMemos: [VoiceMemo]?
    var audioPlayer: AVAudioPlayer!
    var player: AVPlayer!
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
    // Lifecycle methods
    // *************************************
    
    override func viewDidAppear(_ animated: Bool) {
        print("reloaded data")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
       print("VOICE MEMOS WILL DISAPPEAR")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // *************************************
    // View Helpers
    // *************************************
    
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let count = self.voiceMemos?.count {
            print("returning \(count)\n\n\n\n")
            return count
        } else {
            print("returning 0")
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // stop other audio from playing
        self.player = nil
        
        // voice memo value in Firebase 
        // TODO: instantiate VoiceMemo class?
        let value = dataSource?.items[indexPath.row].value as! [String: Any]
        
        // TODO: - Refactor
        // - increase play count
        let url: URL = URL(string: value["download_url"] as! String)!
        self.tappedCell = tableView.cellForRow(at: indexPath) as! VoiceMemoCell
        self.tappedCell.actionSubtext.text = "Playing..."
        playAudio(url: url)
    }
    
    func playAudio(url: URL) {
        let playerItem = AVPlayerItem(url: url)
        
        self.player = AVPlayer(playerItem:playerItem)
        player!.volume = 1.0
        player!.play()
        


        //when player stalls
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerPlaybackStalled(note:)), name: NSNotification.Name.AVPlayerItemPlaybackStalled, object: nil)
        
        // Error log entry
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerErrorEntry(note:)), name: NSNotification.Name.AVPlayerItemNewErrorLogEntry, object: nil)
        
        //when player plays to end time
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        //when player does not finish playing
        NotificationCenter.default.addObserver(self, selector: #selector(self.playerDidNotFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime, object: nil)
        
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
        self.tappedCell.actionSubtext.text = "tap to listen"
    }
        
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
