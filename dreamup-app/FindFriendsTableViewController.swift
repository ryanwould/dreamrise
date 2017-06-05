//
//  FindFriendsTableViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/12/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//
import Firebase
import UIKit

class FindFriendsTableViewController: UITableViewController, UISearchResultsUpdating {
    
    let searchController = UISearchController(searchResultsController: nil)

    @IBOutlet var usersTableView: UITableView!
    
    var usersArray = [NSDictionary?]()
    var filteredUsers = [NSDictionary?]()
    
    var currentUserId : String?
    var currentUserEmail : String?
    var currentUserFriends: NSDictionary?
    
    var databaseRef = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = Colors().spaceCadet
        self.navigationController?.navigationBar.tintColor = UIColor.white
        let currentUser = FIRAuth.auth()?.currentUser
        guard currentUser != nil else { print("current user nil"); return }
        self.currentUserId = currentUser!.uid
        self.currentUserEmail = currentUser!.email
        
//        databaseRef.child("users").child(userId!).observe(FIRDataEventType.value, with: { (snapshot) in
//
//        })
        
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        databaseRef.child("users").queryOrdered(byChild: "username").observe(FIRDataEventType.childAdded, with: { (snapshot) in
            
            let user = snapshot.value as? NSMutableDictionary
            user?.addEntries(from: ["id" : snapshot.key ])
            
            let userEmail = user?["email"] as? String
            if userEmail != self.currentUserEmail {
                
                // add to searchable people
                self.usersArray.append(user)
                
                self.usersTableView.insertRows(at: [IndexPath(row: self.usersArray.count-1, section: 0)], with: UITableViewRowAnimation.automatic)        
            } else {
                let friends = user?["friends"] as? NSDictionary
                
                print("FRIENDS: \(friends)")
                self.currentUserFriends = friends
            }
                
            
        }) { (error) in
            print(error.localizedDescription)
        }

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredUsers.count
        }
        return self.usersArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        
        let user : NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filteredUsers[indexPath.row]
        } else {
            user = self.usersArray[indexPath.row]
        }
        
        cell.textLabel?.text = user?["name"] as? String
        cell.detailTextLabel?.text = user?["username"] as? String
        
        cell.backgroundColor = Colors().spaceCadet

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedUser : NSDictionary?
        
        if searchController.isActive && searchController.searchBar.text != "" {
            selectedUser = filteredUsers[indexPath.row]
        } else {
            selectedUser = self.usersArray[indexPath.row]
        }
        
        if let id = selectedUser?["id"] {
            
            let alertController: UIAlertController?
            let name = selectedUser?["name"] as? String
            
            if ((self.currentUserFriends?.object(forKey: id)) != nil) {
                
                // if already added to friends list// if not added to friends list
                alertController = UIAlertController(title: "Remove Friend", message: "Would you like to remove \(name ?? "name") from friends?", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let removeFriend = UIAlertAction(title: "Remove Friend", style: .default, handler: { action in
                    self.removeFromFriends(friend: selectedUser!)
                })
                
                alertController?.addAction(removeFriend)
                alertController?.addAction(cancel)
                
            } else {
                
                // if not added to friends list
                alertController = UIAlertController(title: "Add Friend", message: "Would you like to add \(name ?? "name") to friends?", preferredStyle: .alert)
                
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let addFriend = UIAlertAction(title: "Add Friend", style: .default, handler: { action in
                    self.addToFriends(friend: selectedUser!)
                })
                
                alertController?.addAction(addFriend)
                alertController?.addAction(cancel)
                
            }
            present(alertController!, animated: true, completion: nil)
        }
    }
    
    func addToFriends(friend: NSDictionary){
        // adding to friends
        
        print("ADDING FRIEND: \(friend)")
        let friendId = friend["id"] as? String
        guard friendId != nil,
              self.currentUserId != nil else { return }
        databaseRef.child("users/\(self.currentUserId!)/friends/\(friendId!)").setValue(true)
        tableView.reloadData()
    }
    
    func removeFromFriends(friend: NSDictionary){
        // removing from friends
        
        print("REMOVING FRIEND: \(friend)")
        let friendId = friend["id"] as? String
        
        guard friendId != nil,
              self.currentUserId != nil else { return }
        databaseRef.child("users/\(self.currentUserId!)/friends/\(friendId!)").removeValue()
        tableView.reloadData()
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
    
    func filterContent(searchText: String)
    {
        self.filteredUsers = self.usersArray.filter { user in
            
            let username = user!["username"] as? String
            return (username?.lowercased().contains(searchText.lowercased()))!
        }
        tableView.reloadData()
    }
    
    @IBAction func dismissFindFriendsViewController(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        // update the search results
        filterContent(searchText: self.searchController.searchBar.text!)
        
    }

}
