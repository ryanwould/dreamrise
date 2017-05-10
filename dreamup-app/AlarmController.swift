//
//  ViewController.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/1/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import MediaPlayer
import Firebase


class AlarmController: UIViewController {

    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var startAlarmButton: UIButton!
    var ref: FIRDatabaseReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let current_user = FIRAuth.auth()?.currentUser
        
        if current_user != nil, current_user?.uid != nil {
            print("CURRENT USER")
            print("PROVIDER: \(current_user?.providerID)")
            print("PROV DATA: \(current_user?.providerData)")
            print("ID: \(current_user!.uid)")
            ref = FIRDatabase.database().reference()
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        timePicker.datePickerMode = .time
        startAlarmButton.layer.cornerRadius = 0
        startAlarmButton.layer.borderWidth = 3
        startAlarmButton.layer.borderColor = UIColor.white.cgColor
        timePicker.setValue(UIColor.white, forKey: "textColor")
        
        
    }
    

    
    // *****************
    // MARK: - Segue
    // *****************
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "settingAlarm" {
            let destinationVC = segue.destination as! AlarmInProgress
            destinationVC.alarmFireTime = timePicker.date
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
   
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
}



