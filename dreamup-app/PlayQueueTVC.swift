//
//  PlayQueueTVC.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/5/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class PlayQueueTVC: UITableViewController {
    
    var tableDataIds = [String]()
    @IBOutlet var tableview: UITableView!
    let defaults = UserDefaultsManager()
    
    @IBAction func unwindToAlarmQueue(segue: UIStoryboardSegue) {}
        
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        //load data if exists
        let defaults = UserDefaultsManager()
        let alarmOrder = defaults.getAlarmQueue()
        
        guard alarmOrder != nil else {
            // alarm order has not been set.
            // tell user to set it up
            print("set your alarm order")
            return
        }
        
        // alarm order is set
        tableDataIds = alarmOrder!
        tableview.reloadData()
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
        return tableDataIds.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "playQueueItemCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! PlayQueueCell

        // Configure the cell...
        let cellData = defaults.getPlaySettingsForId(id: tableDataIds[indexPath.row])
        let displayString = cellData["displayString"] as! String
        cell.displayStringLabel?.text = displayString
        cell.displayMediaTypeLabel?.text = cellData["mediaType"] as? String
        cell.configureIcon()

        return cell
    }
    
    //******************************************************
    // Mark: - Edit tableview
    //******************************************************
    
    
    @IBAction func startEditing(_ sender: UIBarButtonItem) {
        print("is editing")
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let action: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "testing", handler: {_,_ in 
            print("in here maybe?")
        })
        action.backgroundColor = UIColor.blue
        return "Remove"
    }
    
    // Deleting items from Alarm Queue
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let deletedId = tableDataIds[indexPath.row]
            tableDataIds.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            defaults.setAlarmQueue(data: tableDataIds)
            defaults.deletePlaySettingsForId(id: deletedId)
        }
    }

    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = tableDataIds[fromIndexPath.row]
        tableDataIds.remove(at: fromIndexPath.row)
        tableDataIds.insert(itemToMove, at: to.row)
        defaults.setAlarmQueue(data: tableDataIds)
    }

    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    // ***********************************************
    // MARK: - Navigation (Editing alarmqueue items)
    // ***********************************************
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let rowKey = data[indexPath.row][0]
//        print(rowKey)
//        initiateSegue(key: rowKey)
//    }
//    
//    func initiateSegue(key: String) {
//        print("performing segue to \(key)")
//        self.performSegue(withIdentifier: key, sender: key)
//    }
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destinationViewController.
//        // Pass the selected object to the new view controller.
//        print(sender ?? "sender")
//    }
}


extension PlayQueueTVC: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overCurrentContext
    }
    
}


