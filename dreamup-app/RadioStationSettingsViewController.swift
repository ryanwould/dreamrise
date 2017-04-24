//
//  RadioStationSettingsViewController.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/18/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class RadioStationSettingsViewController: UIViewController {

    @IBOutlet weak var picker: UIDatePicker!
    
    var stationTitle: String?
    var streamUrl: String?
    
    @IBAction func pickerChanged(_ sender: Any) {
        print(picker.countDownDuration)
    }
    
    @IBAction func done(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToAlarmQueue", sender: self)
        //create Alarm Queue item
        let defaults = UserDefaultsManager()
    
        guard let stream = streamUrl else {
            print("stream invalid")
            return
        }
        guard let title = stationTitle else {
            print("title invalid")
            return
        }
        defaults.createRadioAlarmItem(stationTitle: title, streamUrl: stream)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        picker.countDownDuration = 5

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
