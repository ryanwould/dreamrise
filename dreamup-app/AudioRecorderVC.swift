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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                        self.loadRecordingUI()
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
   /*
    override func viewDidAppear(_ animated: Bool) {
        lottie.play()
    }
    
    override func viewDidLayoutSubviews() {
        lottie.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height * 0.3)
        view.addSubview(lottie)
    }
 */
    
    //**********************************
    // MARK: - Audio Setup
    //**********************************
    
    // load recording button
    func loadRecordingUI(){
        recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        recordButton.center.x = self.view.center.x - 125
        recordButton.center.y = self.view.center.y + 225
        recordButton.setImage(UIImage(named: "big-mic"), for: .normal)
        recordButton.imageView?.tintColor = UIColor.red
        recordButton.layer.cornerRadius = 0.5 * recordButton.layer.bounds.width
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        recordButton.layer.borderWidth = 4
        recordButton.layer.borderColor = UIColor.red.cgColor
        recordButton.backgroundColor = UIColor.white
        view.addSubview(recordButton)
    }
    
    func buttonStartRecording() {
        recordButton.backgroundColor = UIColor.red
        recordButton.imageView?.tintColor = UIColor.white
    }
    
    func buttonDoneRecording() {
        print("button done recording")
        recordButton.backgroundColor = UIColor.clear
        recordButton.imageView?.tintColor = UIColor.red
    }
    
    func doneRecording() {
        //show x
        xButton = UIButton(frame: CGRect(x: 25, y: 50, width: 50, height: 50))
        xButton.setImage(UIImage(named: "close"), for: .normal)
        xButton.addTarget(self, action: #selector(resetRecordingView), for: .touchUpInside)
        view.addSubview(xButton)
        
        //show send
        nextButton = UIButton(frame: recordButton.frame)
        nextButton.center.x = self.view.frame.maxX - 50
        nextButton.setImage(UIImage(named: "forward"), for: .normal)
        nextButton.addTarget(self, action: #selector(sendAudio), for: .touchUpInside)
        view.addSubview(nextButton)
        
        //remove recordButton
        recordButton.isHidden = true
    }
    
    
    //******************************************
    // MARK: - SEGUE
    //******************************************
    
    func sendAudio(){
        print("IN SEND AUDIO")
        performSegue(withIdentifier: "sendAudio", sender: nil)
        nextButton.isHidden = true
        xButton.isHidden = true
        playButton.isHidden = true
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
    // MARK: - Reset View
    //******************************************
    
    func resetRecordingView(){
        recordButton.isHidden = false
        audioRecorder = nil
        
        //hide other buttons
        xButton.isHidden = true
        nextButton.isHidden = true
        playButton.isHidden = true
    }
    
    func loadPlaybackUI(){
        //playButton.frame = recordButton.frame
        playButton = UIButton(frame: CGRect(x: 0, y: 0, width: 75, height: 75))
        playButton.center.x = self.view.center.x
        playButton.center.y = self.view.center.y + 225
        playButton.setTitle("Tap to play", for: .normal)
        playButton.setTitleColor(UIColor.blue, for: .normal)
        playButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.title1)
        playButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        playButton.backgroundColor = UIColor.clear
        playButton.layer.borderWidth = 10
        playButton.layer.borderColor = UIColor.blue.cgColor
        view.addSubview(playButton)
    }
    
    func animateButtonRepeated(){
        UIView.animateKeyframes(withDuration: 1.0, delay: 0.0, options: [.repeat], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/2, animations: {
                self.recordButton.transform = CGAffineTransform.identity.scaledBy(x: 1.25, y: 1.25)
            })
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2, animations: {
                self.recordButton.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
            })
        }, completion: nil)
    }
    
    func playAudio(_ sender: AnyObject) {
        print("tapped button")
        playButton.setTitle("Playing...", for: .normal)
        
        do {
            //try to play through speakers
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
        } catch {
            print("couldn't play through speakers")
        }
        
        if audioRecorder?.isRecording == false {
            recordButton.isEnabled = false
            
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
        
        buttonStartRecording()
        
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
        buttonDoneRecording()
        
        if success {
            //recordButton.setTitle("Tap to record", for: .normal)
            print("recorded successfully")
            loadPlaybackUI()
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
        //reset view
        doneRecording()
    }
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) {
        print("Audio Record Encode Error")
    }
}

extension AudioRecorderVC: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playButton.setTitle("Tap to play", for: .normal)
        print("did finish playing")
        recordButton.isEnabled = true
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    
}
