//
//  CompleteSignupViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/11/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Firebase

class CompleteSignupViewController: UIViewController {
    
    var usersRef: FIRDatabaseReference!
    var usernamesRef: FIRDatabaseReference!
    var voiceMemosRef: FIRDatabaseReference!
    var user: FIRUser?

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    @IBAction func actionButton(_ sender: Any) {
        //self.ref.child("users").child(user.uid).setValue(["username": username])
        
        // validate username uniqueness
        self.usernamesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard self.usernameTextField.text != nil else { print("username is nil"); return }
            guard self.nameTextField.text != nil else { print("name is nil"); return }
            
            let username = self.usernameTextField.text!
            let name = self.nameTextField.text!
            
            if snapshot.hasChild("\(username)"){
                let alertController = UIAlertController(title: "Error", message: "The username \(username) has already been taken. Please try another!", preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                
            } else {
                // all good, username is unique!
                
                // write username
                self.usernamesRef.child("/\(username)").setValue(true)
                
                // complete users profile
                if let user = self.user {
                    let userValue = [
                        "email": user.email ?? "unknown@example.com",
                        "username": username,
                        "name": name,
                        "friends": [],
                    ] as [String : Any]
                    
                    //set value in users
                    self.usersRef.child("\(user.uid)").setValue(userValue)
                    
                    // create voice memos node for new user
                    self.voiceMemosRef.child("\(user.uid)").setValue([])
                    
                    // Present "Home" ViewController (MainViewController.swift)
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "Home")
//                    self.present(vc!, animated: true, completion: nil)
                    
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Home")
                    self.present(vc, animated: true, completion: nil)

                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let user = user {
            print("NEW USER: \(user.debugDescription)")
        }
        
        self.usersRef = FIRDatabase.database().reference().child("users")
        self.voiceMemosRef = FIRDatabase.database().reference().child("voice_memos")
        self.usernamesRef = FIRDatabase.database().reference().child("usernames")
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GO_TO_MAIN" {
        }
    }
}
