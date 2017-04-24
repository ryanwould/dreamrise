//
//  AlarmInProgress.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/19/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class AlarmInProgress: UIViewController {
    
    @IBOutlet weak var alarmFireDateLabel: UILabel!
    var alarmFireTime: Date?
    let defaults = UserDefaultsManager()

    @IBAction func didCancelAlarm(_ sender: Any) {
        // undo setup
        undoViewSetup()
        dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // setup
        setupView()
        
        //alarm
        guard alarmFireTime != nil else {
            print("alarm not set"); return
        }
        print(alarmFireTime!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupView(){
        self.view.backgroundColor = Colors().darkBlue
        
        // Hide the status bar
        UIApplication.shared.isStatusBarHidden = true
        
        // Disable screen going to sleep
        UIApplication.shared.isIdleTimerDisabled = true
        
        // set alarm fire date label
        guard alarmFireTime != nil else {
            return
        }
        formatAlarmTime(time: alarmFireTime!)
        
    }
    
    func undoViewSetup(){
        UIApplication.shared.isStatusBarHidden = false
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    func formatAlarmTime(time: Date) {
        let localTimeZone = TimeZone.current.identifier
        let f = DateFormatter()
        f.locale = Locale(identifier: localTimeZone)
        f.dateFormat = "h:mm a"
        alarmFireDateLabel.text = f.string(from: time)
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
