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

class SendAudioTableViewController: UITableViewController {
   
    var audioFileUrl: URL?
    var friends = [User]()
    var ref: FIRDatabaseReference!
    var storageRef: FIRStorageReference!
    fileprivate var _refHandle: FIRDatabaseHandle?
    var dataSource: FUITableViewDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Got to sendaudiotableviewcontroller \(audioFileUrl)")
        ref = FIRDatabase.database().reference().child("users")
        
//        ref.observe(.value, with: { snapshot in
//            print("SNAP HERE: \(snapshot)")
//        })
        
//        ref.observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            print("VALUE: \(value)")
//            
//            // ...
//        }) { (error) in
//            print(error.localizedDescription)
//        }
        
        tableView.register(FriendCell.self, forCellReuseIdentifier: "Friend Cell")
        
        tableView.dataSource = dataSource
        
        print("\nDATASOURCE: \(dataSource)")
        self.dataSource = self.tableView.bind(to: self.ref.child("8b10bZJWEjRQEDTf74mB4nPhyJG2/friends/"), populateCell: { (tableView, indexPath, snapshot) in
            let value = snapshot.value as? NSDictionary
            let key = snapshot.key || ""
            print("SNAPSHOT: \(key)")
            
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell")
            
            return cell!
        })
        
        print("\nDATASOURCE: \(dataSource)")
        
        
        
        
        //configureDatabase()
        //configureStorage()
        
    
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    func configureDatabase() {
        ref = FIRDatabase.database().reference()
        //listen for new firends
        // TODO: Swap out user id
        _refHandle = self.ref.child("users/8b10bZJWEjRQEDTf74mB4nPhyJG2/friends").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else {return}
            print("SNAPSHOT: \(snapshot)")
            // var user = User(uid: snapshot.id, name: <#T##String#>, email: <#T##String#>, username: <#T##String#>)
            // strongSelf.friends.append(snapshot)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.friends.count-1, section: 0)], with: .automatic)
        })
    }
    
    func configureStorage() {
        storageRef = FIRStorage.storage().reference()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    /*
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell") as! FriendCell
        //unpack friend from Firebase Data Snapshot
        
        let friendSnapshot: FIRDataSnapshot! = self.friends[indexPath.row]
        guard let friend = friendSnapshot.value as? 
        /* switch self.friends.count {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Empty Cell")
            return cell!
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Friend Cell", for: indexPath) as! FriendCell
            cell.indicator = SelectedIndicator(selected: false)
            cell.name.text = friends[indexPath.row].name
            return cell
        }
        */
     }
 */
    
    func getFriends() {
        print("calling getFriends")
        ref.queryOrdered(byChild: "friends").observe(.childAdded, with: { (snapshot) in
            print(snapshot.value ?? "snapshot blank")
        })
    }
    
    func getQuery() -> FIRDatabaseQuery {
        return (ref?.child("8b10bZJWEjRQEDTf74mB4nPhyJG2/friends/"))!
        
    }
    
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
