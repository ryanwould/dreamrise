//
//  SendAudioTableViewController.swift
//  Pods
//
//  Created by Razgaitis, Paul on 3/26/17.
//
//

import UIKit
import Firebase
import FirebaseDatabaseUI
import SnapKit

class SendAudioTableViewController: UITableViewController {
   
    // Audio file
    var audioFileUrl: URL?
    var audioFileName: String?
    
    // Friends
    var friends = [String: String]()
    var selectedFriends = [String: String]()
    
    // Firebase references
    var usersRef: FIRDatabaseReference!
    var voiceMemosRef: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    var dataSource: FUITableViewDataSource?
    
    var recipientsBar: RecipientBarView?
    var recipientsBarIsShowing: Bool = false

    
    override func viewWillDisappear(_ animated: Bool) {
        print("VIEW WILL DISAPPEAR")
        if recipientsBarIsShowing {
            hideRecipientsBar()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup firebase
        createStorageRef()
        createDatabaseRefs()
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Friend Cell")
        
        tableView.dataSource = dataSource
        
        //TODO GET CURRENT USER ID
        
        self.dataSource = self.tableView.bind(to: self.usersRef.child("8b10bZJWEjRQEDTf74mB4nPhyJG2/friends/"), populateCell: { (tableView, indexPath, snapshot) in
            let value = snapshot.value
            let key = snapshot.key
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell") as! FriendCell
            
            self.usersRef.child("\(key)").observe(.value, with: { (snap) in
                let key = snap.key as! String
                let user = snap.value as? [String: Any]
                
                let name = user?["name"] as? String
                
                if let name = name {
                    cell.name.text = name
                    cell.userId = key
                    
                    self.friends[key] = name
                    print("FRIENDS? -> \(self.friends[key])")
                }
            })
            return cell
        })
    }
    
    
    
    // ***********************
    // MARK: - FIREBASE SETUP
    // ***********************
    
    func createStorageRef(){
        let storage = FIRStorage.storage()
        self.storageRef = storage.reference()
    }
    
    func createDatabaseRefs() {
        usersRef = FIRDatabase.database().reference().child("users")
        voiceMemosRef = FIRDatabase.database().reference().child("voice_memos")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ***********************
    // MARK: - Table view data source
    // ***********************
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let key = self.dataSource?.items[indexPath.row].key
        print("SELECTED: \(indexPath.row)")
        print(key!)
        print("FRIEND: \(self.friends[key!])")
        
        let selectedCell = tableView.cellForRow(at: indexPath) as! FriendCell
        
        selectedCell.toggleStatus()
        
        //add to selected Friends, or remove if present
        let keyExists = self.selectedFriends[key!] != nil
        
        if keyExists {
            self.selectedFriends.removeValue(forKey: key!)
        } else {
            self.selectedFriends[key!] = self.friends[key!]
            selectedCell.active = true
        }
        
        print(self.selectedFriends.description)
        
        print(self.selectedFriends.count)
        
        if self.selectedFriends.count > 0 && !recipientsBarIsShowing {
            showRecipientsBar()
        }
        
        if self.selectedFriends.count == 0 && recipientsBarIsShowing {
            hideRecipientsBar()
        }
        
        guard self.recipientsBar != nil else { return }
        self.recipientsBar?.recipients.text = self.selectedFriends.description
    }
    
    func showRecipientsBar(){
        self.recipientsBarIsShowing = true
        
        let superview = self.navigationController?.view
        self.recipientsBar = RecipientBarView.instanceFromNib()
        self.recipientsBar?.parentView = self
        
        guard superview != nil, recipientsBar != nil else { print("something is nil"); return }
        
        let scrollview = self.recipientsBar?.scrollview
        self.recipientsBar?.scrollview.contentSize = CGSize(width: 100.0, height: 100.0)
        
        superview!.addSubview(recipientsBar!)
        recipientsBar!.backgroundColor = Colors().blue
        recipientsBar!.snp.makeConstraints({ (make) -> Void in
            make.width.equalToSuperview()
            make.bottom.equalTo((superview!.snp.bottom)).offset(-49)
        })
    }
    
    func sendAudio() {
        print("sending audio")
        print(self.selectedFriends.description)
        
        //*********************
        // Upload file
        //*********************
        
        // File located on disk
        if let audioFileUrl = audioFileUrl, let audioFileName = audioFileName {
            
            let audioRef = storageRef.child("voice_memos/\(audioFileName)")
            
            let uploadTask = audioRef.putFile(audioFileUrl, metadata: nil) { metadata, error in
                if let error = error {
                    // Uh-oh, an error occurred!
                    print("ERROR! \(error)")
                } else {
                    // Metadata contains file metadata such as size, content-type, and download URL.
                    let downloadURL = metadata!.downloadURL()
                    print("DOWNLOAD URL: \(downloadURL)")
                    
                    
                    //***********************************
                    // SEND FILE TO SELECTED RECIPIENTS
                    //**********************************
                    
                    // TODO: Move to background
                    guard downloadURL != nil else { return }
                    self.shareVoiceMemo(downloadURL: "\(downloadURL!)")
                }
            }
        }
    }
    
    func shareVoiceMemo(downloadURL: String){
        
        for friend in self.selectedFriends {
            let key = voiceMemosRef.child("\(friend.key)").childByAutoId().key
            let voiceMemo: [String: Any] = [
                "download_url": downloadURL,
                "expires_at": String(Date().timeIntervalSince1970 + (24 * 60 * 60)),
                "sent_at": String(Date().timeIntervalSince1970),
                "listened_at": "never",
                "play_count": 0,
                "saved": 0,
                "sender": "CURRENT_USER_ID",
                ]
            self.voiceMemosRef.child("\(friend.key)/\(key)").setValue(voiceMemo)
            print("writing to voice_memos/\(friend.key)/\(key)/")
        }
        self.recipientsBar?.recipients.text = ""
        self.hideRecipientsBar()
        self.unwindToMenu()
    }
    
    
    
    func hideRecipientsBar(){
        self.recipientsBarIsShowing = false
        let superview = self.navigationController?.view
        
        guard superview != nil, recipientsBar != nil else {
            print("something is nil");
            return
        }
        
        superview!.addSubview(recipientsBar!)
        recipientsBar?.removeFromSuperview()
    }
    
     // MARK: - Navigation
    
    func unwindToMenu(){
        self.performSegue(withIdentifier: "unwindToMenu", sender: self)
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let dest = segue.destination
        if let nav = dest.navigationController as? AudioRecorderVC {
            nav.resetRecordingView()
            nav.loadRecordingUI()
        }
        print("DESTINATION: \(dest)")
        
    }
    
}
