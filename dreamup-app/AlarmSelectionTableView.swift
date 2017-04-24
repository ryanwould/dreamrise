//
//  AlarmSelectionTableView.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class AlarmSelectionTableView: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded static table")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    //******************************************
    // MARK: - Navigation
    //******************************************
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            print("no segue identifier")
            return
        }
        switch identifier {
        case "radio":
            print("segueing to radio")
        case "podcast":
            print("segueing to podcasts")
        case "radio":
            print("segueing to playlists")
        default:
            print("unknown segue")
        }
    }
}
