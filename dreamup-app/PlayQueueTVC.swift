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
    
    @IBAction func unwindToPlayQueue(segue: UIStoryboardSegue) {}
        
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
        cell.selectionStyle = .none
        return cell
    }
    
    //******************************************************
    // Mark: - Edit tableview
    //******************************************************
    
    
    @IBAction func startEditing(_ sender: UIBarButtonItem) {
        let alarmQueue = defaults.getAlarmQueue()
        guard alarmQueue != nil else  { return }
        for item in alarmQueue! {
            print(item)
        }
        self.isEditing = !self.isEditing
    }
    
    override func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        let action: UITableViewRowAction = UITableViewRowAction(style: UITableViewRowActionStyle.default, title: "testing", handler: {_,_ in
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
}

extension PlayQueueTVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.overCurrentContext
    }
}
