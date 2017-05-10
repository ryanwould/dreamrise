//
//  RecorderView.swift
//  dreamup-app
//
//  Created by Razgaitis, Paul on 5/8/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import Foundation
import NVActivityIndicatorView

class RecorderView: UIView {
    
    var parent: AudioRecorderVC?
    
    enum recordingStatus {
        case notStarted
        case inProgress
        case finished
    }
    
    var status = recordingStatus.notStarted
    var timer = Timer()
    var seconds = 0

    var recordingIndicator: NVActivityIndicatorView?
    var playingAudioIndicator: NVActivityIndicatorView?
    
    @IBOutlet weak var recordingPlaceholder: UIView!
    @IBOutlet weak var playingPlaceholder: UIView!
    
    @IBOutlet weak var tapToRecordButton: UIButton!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    
    // MARK: - Actions
    @IBAction func cancelRecording(_ sender: Any) {
        print("cancel recording")
        parent?.resetRecordingView()
        self.seconds = 0
    }
    
    @IBAction func sendRecording(_ sender: Any) {
        print("send recording")
        parent?.sendAudio()
    }
    
    func timerAction(){
        self.seconds += 1
        self.recordingTimeLabel.text = labelFromSeconds(seconds: seconds)
    }
    
    func labelFromSeconds(seconds: Int) -> String {
        var (h,m,s) = secondsToHoursMinutesSeconds(seconds: seconds)
        print("\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s))")
        
        return "\(String(format: "%02d", h)):\(String(format: "%02d", m)):\(String(format: "%02d", s))"
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func resetView(){
        self.status = .notStarted
        self.tapToRecordButton.setTitle("TAP TO RECORD", for: .normal)
    }
    
    func stoppedPlaying(){
        print("stopped playing")
        self.tapToRecordButton.setTitle("PLAY AUDIO", for: .normal)
        self.tapToRecordButton.isEnabled = true
        
        self.playingAudioIndicator?.stopAnimating()
    }
    
    @IBAction func recordButtonTapped(_ sender: Any) {
        switch self.status {
        case .notStarted:
            // start recording
            self.status = recordingStatus.inProgress
            
            // start timer
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerAction), userInfo: nil, repeats: true);
            
            // set button text
            self.tapToRecordButton.setTitle("RECORDING", for: .normal)
            
            // make recording indicator
            let animation = NVActivityIndicatorView(frame: recordingPlaceholder.frame, type: NVActivityIndicatorType.ballClipRotatePulse)
            animation.startAnimating()
            self.addSubview(animation)
            self.recordingIndicator = animation
            
            // start recording in parent view
            parent?.startRecording()
            
        case .inProgress:
            // stop recording
            self.status = recordingStatus.finished
            
            // stop timer
            self.timer.invalidate()
            
            //stop animation
            if let inidcator = self.recordingIndicator {
                inidcator.stopAnimating()
            }
            
            // set button text
            self.tapToRecordButton.setTitle("PLAY AUDIO", for: .normal)
            
            // stop recording successfully in parent view
            parent?.finishRecording(success: true)
            
        case .finished:
            // play recorded audio
            parent?.playAudio(self)
            
            // make playback indicator
            let animation = NVActivityIndicatorView(frame: self.playingPlaceholder.frame, type: NVActivityIndicatorType.audioEqualizer)
            animation.startAnimating()
            self.addSubview(animation)
            self.playingAudioIndicator = animation
            
            
            self.tapToRecordButton.setTitle("PLAYING", for: .normal)
            self.tapToRecordButton.isEnabled = false
            
            
        }
        
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
