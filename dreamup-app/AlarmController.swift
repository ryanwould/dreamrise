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
        timePicker.minuteInterval = 1
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
            destinationVC.alarmFireTime = roundTimeToMinute(time: timePicker.date)
        }
    }
    
    func roundTimeToMinute(time: Date) -> Date {
        let timeInterval = floor(time.timeIntervalSinceReferenceDate / 60.0) * 60.0
        let newDate = Date(timeIntervalSinceReferenceDate: timeInterval)
        return newDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
   
    @IBAction func startAlarm(_ sender: Any) {
        // exit if nothing in queue
        let defaults = UserDefaultsManager()
        let alarmQueue = defaults.getAlarmQueue()
        
        print(alarmQueue)
        
        if (alarmQueue == nil || alarmQueue?.count == 0) {
            let alert = UIAlertController(title: "You don't have any alarms set!",
                                          message: "You can add a few in the Alarm Queue tab below",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in
                // perhaps use action.title here
                print("exiting")
            })
            self.present(alert, animated: true)
        } else {
            self.performSegue(withIdentifier: "settingAlarm", sender: nil)
        }
    }
    @IBAction func dismiss(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pickerChanged(_ sender: UIDatePicker) {
        print(sender.date)
    }
}



