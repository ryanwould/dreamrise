//
//  AudioRecorderVC.swift
//  testing
//
//  Created by Razgaitis, Paul on 2/19/17.
//  Copyright © 2017 Razgaitis, Paul. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseStorage
import Firebase
import FirebaseDatabase
import SnapKit
import NVActivityIndicatorView


class AudioRecorderVC: UINavigationController {
    
    //***********************
    // MARK: - Audio
    //***********************
    
    var recordButton: UIButton!
    var playButton: UIButton!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer?
    var xButton: UIButton!
    var nextButton: UIButton!
    var filename: String?
    var ref: FIRDatabaseReference!
    
    // *************************************
    // Recorder View
    // *************************************
    
    var recorderView: RecorderView?
    
    // *************************************
    // View LifeCycle Methods
    // *************************************
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barStyle = UIBarStyle.black
        self.navigationBar.tintColor = UIColor.white
        
        //***********************
        // MARK: - Firebase
        //***********************
        
        let storage = FIRStorage.storage()
        
        
        // Points to the root reference
        let storageRef = FIRStorage.storage().reference()
        let pvmRef = storageRef.child("voice_messages")
        let userId = FIRAuth.auth()?.currentUser?.uid
        let timestamp = Date().timeIntervalSince1970.rounded()
        
        
        //if let id = userId {
        var id = "id"
        print("\(id)\(timestamp)")
        filename = "pvm_\(id)_\(timestamp)"
        //}
        
        //create recording session
        recordingSession = AVAudioSession.sharedInstance()
        
        // try to set the recording session - load record button if success
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.prepareRecordingUI()
                    } else {
                        //failed to record
                        // TOOD: throw error asking for mic permissions
                        print("no permission to record")
                    }
                }
            }
        } catch {
            //failed to record
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("AUDIORECORDERVC will disappear")
    }
    
    //**********************************
    // MARK: - Audio Setup
    //**********************************
    
    // load recording button
    func prepareRecordingUI(){
        
        // make recorderView
        self.recorderView = Bundle.main.loadNibNamed("RecorderView", owner: self, options: nil)?[0] as! RecorderView
        self.recorderView?.parent = self
        
        // set recorderView frame
        let recorderViewFrame = CGRect(x: self.view.frame.minX,
                                       y: self.view.frame.maxY - 75,
                                       width: self.view.frame.width,
                                       height: 200.0)
        guard recorderView != nil else { return }
        self.recorderView!.frame = recorderViewFrame
        self.view.addSubview(self.recorderView!)
    }
    
    func startRecordingUI() {
        guard recorderView != nil else { return }
        
        // move recorderView up
        moveRecorderView(position: 1)
    }
    
    func finishRecordingUI() {
        // set recorderView frame
        guard recorderView != nil else { return }
        
        // move recorderView up
        moveRecorderView(position: 2)
    }
    
    //******************************************
    // MARK: - Reset View
    //******************************************
    
    func resetRecordingView(){
        audioRecorder = nil
        
        // create recorderView.resetView()
        self.recorderView!.resetView()
        
        // move recorder view back into place
        moveRecorderView(position: 0)
    }
    
    //******************************************
    // MARK: - SEGUE
    //******************************************
    
    func sendAudio(){
        
        // move recorderView off screen
        moveRecorderView(position: 3)
        
        // segue to send audio View controller
        performSegue(withIdentifier: "sendAudio", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sendAudio" {
            
            let vc = segue.destination as! SendAudioTableViewController
            guard filename != nil else { return }
            let file = getDocumentsDirectory().appendingPathComponent("\(filename!).m4a")
            print("FILE URL..?  \(file.absoluteURL)")
            vc.audioFileUrl = file
            vc.audioFileName = filename
        }
    }
    
    //******************************************
    // MARK: - RECORDERVIEW UI
    //******************************************
    
    func moveRecorderView(position: Int) {
        let screenHeight = self.view.bounds.height
        switch position {
        case 0:
            print("moving to position 0 - TAP TO RECORD")
            UIView.animate(withDuration: 0.25, animations: {
                self.recorderView!.frame.origin.y = screenHeight - 75
            })
        case 1:
            print("moving to position 1 - RECORDING")
            UIView.animate(withDuration: 0.25, animations: {
                self.recorderView!.frame.origin.y = screenHeight - 125
            })
        case 2:
            print("moving to position 2 - DONE RECORDING")
            UIView.animate(withDuration: 0.25, animations: {
                self.recorderView!.frame.origin.y = screenHeight - 175
            })
        case 3:
            print("moving to position 3 - OFF SCREEN")
            UIView.animate(withDuration: 0.25, animations: {
                self.recorderView!.frame.origin.y = screenHeight
            })
        default:
            print("DEFAULT CASE")
            UIView.animate(withDuration: 0.25, animations: {
                self.recorderView!.frame.origin.y = screenHeight - 75
            })
        }
        
    }
    
    
    //******************************************
    // MARK: - AUDIO METHODS
    //******************************************
    
    func playAudio(_ sender: AnyObject) {
        print("tapped button")
        
        do {
            //try to play through speakers
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("couldn't play through speakers")
        }
        
        if audioRecorder?.isRecording == false {
            
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
                audioPlayer!.delegate = self
                
                audioPlayer!.prepareToPlay()
                audioPlayer!.play()
            } catch let error as NSError {
                print("audioPlayer error: \(error.localizedDescription)")
            }
        }
    }
    
    func startRecording(){
        guard filename != nil else {
            print("filename was nil")
            return
        }
        
        startRecordingUI()
        
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(filename!).m4a")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            print("recording...")
            //animateButtonRepeated()
            //recordButton.setTitle("Tap to Stop", for: .normal)
        } catch {
            print("catch recording fail")
            finishRecording(success: false)
        }
    }
    
    func finishRecording(success: Bool){
        audioRecorder.stop()
        
        if success {
            //recordButton.setTitle("Tap to record", for: .normal)
            print("recorded successfully")
            finishRecordingUI()
        } else {
            //recordButton.setTitle("Tap to re-record", for: .normal)
            print("recording failed")
        }
    }
    
    func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension AudioRecorderVC: AVAudioRecorderDelegate {
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
}

extension AudioRecorderVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let recorderView = self.recorderView {
            recorderView.stoppedPlaying()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    
}
