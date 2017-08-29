//
//  PodcastConfirmStep.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/19/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit

class PodcastConfirmStep: UIViewController {
    
    @IBOutlet weak var picker: UIDatePicker!
    var podcast: Podcast?

    @IBAction func pickerChanged(_ sender: Any) {
        print(picker.countDownDuration)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func AddToAlarmQueue(_ sender: Any) {
        let defaults = UserDefaultsManager()
        
        guard let podcast = podcast else {
            print("something wrong with podcast")
            return
        }
        defaults.createPodcastAlarmItem(podcast: podcast)
        //segue back
        self.performSegue(withIdentifier: "unwindToAlarmQueue", sender: self)

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
