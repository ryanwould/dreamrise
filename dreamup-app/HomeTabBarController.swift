//
//  HomeTabBarController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 4/23/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Firebase

class HomeTabBarController: UITabBarController {
    
    var ref: FIRDatabaseReference!
    
    override func viewDidAppear(_ animated: Bool) {
        print("in view did appear in HOMETABBARCONTROLLER")
        if FIRAuth.auth()?.currentUser == nil {
            self.performSegue(withIdentifier: "signIn", sender: nil)
        } else {
            print("\n\n\nUSER IS \(FIRAuth.auth()?.currentUser?.uid)\n\n\n")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        
        ref = FIRDatabase.database().reference()
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI
    
    func configureView() {
        self.tabBar.barTintColor = UIColor.darkGray
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
