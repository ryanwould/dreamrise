//
//  SideMenuViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/10/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Firebase

class SideMenuViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!

    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        ref = FIRDatabase.database().reference()
        
        if let user = FIRAuth.auth()?.currentUser {
            let id = user.uid
            
            self.ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
                
                let user = snapshot.value as? [String: Any]
                let fullname = user?["name"] as? String
                let username = user?["username"] as? String
                
                guard fullname != nil,
                        username != nil else { return }
                
                self.usernameLabel.text = username
                self.fullnameLabel.text = fullname
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = navigationController
        print("\(vc)")
        guard vc != nil else { print("\(vc)"); return }

        switch indexPath.row {
        case 0:
            print("")
        case 1:
            print("MENU - ALARM")
        case 2:
            print("MENU - ALARM ORDER")
        case 3:
            print("MENU - VOICE MEMOS")
        case 4:
            print("MENU - SEARCH PEOPLE")
        case 5:
            print("MENU - INVITE FRIENDS")
        case 6:
            print("MENU - SETTINGS")
        case 7:
            print("MENU - SIGN OUT")
            signOut()
        default:
            print("MENU - UNDEFINED")
        }
    }
    
    func signOut() {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "SignUp")
                present(vc, animated: true, completion: nil)
                
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "SIGN_OUT" {
            do {
                try FIRAuth.auth()?.signOut()
            } catch {
                print("Error signing out")
            }
        }
    }

}
