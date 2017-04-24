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

class VoiceMemosTableViewController: UITableViewController {
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) {}
    
    var voiceMemosRef: FIRDatabaseReference!
    var dataSource: FUITableViewDataSource?
    
    //**************************************
    // MARK: - Firebase
    //**************************************
    
    
    func createDatabaseRefs() {
        voiceMemosRef = FIRDatabase.database().reference().child("voice_memos")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        createDatabaseRefs()
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Friend Cell")
        
        tableView.dataSource = dataSource
        
        //TODO GET CURRENT USER ID
        self.dataSource = self.tableView.bind(to: self.voiceMemosRef.child("5WPAj4To3thiFPTgqtWilhGDnyT2/"), populateCell: { (tableView, indexPath, snapshot) in
            let value = snapshot.value
            let key = snapshot.key
            let cell = tableView.dequeueReusableCell(withIdentifier: "voice_memo_cell") as! VoiceMemoCell
            print("KEY: \(key)")
            print("KEY: \(value)")
            
            if let value = value {
                
            }
            
//            self.usersRef.child("\(key)").observe(.value, with: { (snap) in
//                let key = snap.key as! String
//                let user = snap.value as? [String: Any]
//                
//                let name = user?["name"] as? String
//                
//                if let name = name {
//                    cell.name.text = name
//                    cell.userId = key
//                    
//                    self.friends[key] = name
//                    print("FRIENDS? -> \(self.friends[key])")
//                }
//            })
            return cell
        })

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

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
