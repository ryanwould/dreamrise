//
//  PodcastDetailViewController.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 8/28/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import MediaPlayer

class PodcastDetailViewController: UIViewController {
    
    var podcast: Podcast?
    
    // MARK: Outlets

    @IBOutlet weak var podcastImage: UIImageView!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var podcastDescription: UILabel!
    
    // MARK: Actions
    
    @IBAction func add(_ sender: Any) {
        
        if let podcast = self.podcast {
            addToAlarmQueue(podcast: podcast)
            
            let alertController = UIAlertController(title: "Added Podcast!", message: "\(podcast.episodeTitle) was added to your Alarm Queue", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //configure view
        if let podcast = self.podcast {
            self.configurePodcast(podcast: podcast)
        }
        
        configureButton()

        // Do any additional setup after loading the view.
    }
    
    func addToAlarmQueue(podcast: Podcast?) {
        let defaults = UserDefaultsManager()
        
        guard let podcast = podcast else {
            print("something wrong with podcast")
            return
        }
        defaults.createPodcastAlarmItem(podcast: podcast)
    }
    
    func configurePodcast(podcast: Podcast) {
        authorLabel.text = podcast.podcastTitle
        episodeTitle.text = podcast.episodeTitle
        podcastImage.image = podcast.image?.image(at: CGSize(width: 60, height: 60))
        duration.text = stringFromTimeInterval(interval: podcast.duration)
    }
    
    func configureButton(){
        addButton.layer.cornerRadius = 0
        addButton.layer.borderWidth = 3
        addButton.layer.borderColor = UIColor.white.cgColor
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

extension PodcastDetailViewController {
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        
        let ti = NSInteger(interval)
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d:%0.2d",hours,minutes,seconds) as String
    }

}


