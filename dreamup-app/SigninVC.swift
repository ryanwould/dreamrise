//
//  SignupVC.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/20/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase


class SigninVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    var ref: FIRDatabaseReference!
    
    //***************************
    // Check if signed in already
    //***************************
    
    override func viewWillAppear(_ animated: Bool) {
        ref = FIRDatabase.database().reference()
        
//        if FIRAuth.auth()?.currentUser != nil {
//            self.performSegue(withIdentifier: "signIn", sender: nil)
//        }
        
        emailField.text = "prazgaitis@gmail.com"
        passwordField.text = "password"
    }
    
    
    @IBAction func didTapSignIn(_ sender: Any) {
        
        guard let email = self.emailField.text, let password = self.passwordField.text else {
            print("email/password can't be blank")
            return
        }
        
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            
            guard let user = user, error == nil else {
                print("FIREBASE ERROR: \(error)")
                return
            }
            
            self.ref.child("users").child(user.uid).observeSingleEvent(of: .value, with: {(snapshot) in
    
                //check if user exists
                print("snapshot exists -> \(snapshot.exists())")
                
//                guard snapshot.exists() else {
//                    print("NO SNAPSHOT: \(snapshot)")
//                    return
//                }
                
                print("SNAPSHOT: \(snapshot.value)")
                self.dismiss(animated: true, completion: nil)
                
            })
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
