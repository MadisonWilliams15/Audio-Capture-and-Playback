//
//  ViewController.swift
//  Audio Capture and Playback
//
//  Created by Madison Williams on 4/7/19.
//  Copyright © 2019 Madison Williams. All rights reserved.
//

import UIKit
import AVKit

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {

    @IBOutlet weak var recordBarButton: UIBarButtonItem!
    @IBOutlet weak var playBarButton: UIBarButtonItem!
    var audioSession: AVAudioSession?
    var audioFile: URL?
    var audioRec: AVAudioRecorder?
    var audioPlayer: AVAudioPlayer?
    var fileManager: FileManager?
    var docDirectoryURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        recordBarButton.isEnabled = false;
        playBarButton.isEnabled = false;
        
        initFileStorage()
        initAudioSession()
        initAudioRec()
        
        //ask to record audio
        audioSession = AVAudioSession.sharedInstance()
        
        audioSession?.requestRecordPermission() {
            [unowned self] allowed in
            if allowed {
                // proceed to do whatever is needed to record
                self.recordBarButton.isEnabled = true
               // self.initAudioRec()
            } else {
                // don't let the app record because permission was denied
                print("Cannot record audio.")
            }
        
        }
    }

    
    @IBAction func recordBarButtonPressed(_ sender: Any) {
        if(recordBarButton.image == UIImage(named:"record")){//start recording
        recordBarButton.image = UIImage(named: "stop")
        //record Audio and save
        audioRec?.record()
        }else{//stop recording
            audioRec?.stop()
            recordBarButton.image = UIImage(named: "record")
            playBarButton.isEnabled = true
        }
        
    }
    
    @IBAction func playBarButtonPressed(_ sender: Any) {
        
        playBarButton.image = UIImage(named: "stop")
        
        guard let audioFile = audioFile else {
            print("Cant play audio")
            return
        }
        
        guard let audioRec = audioRec, audioRec.isRecording == false else {
            print("Cant play while recording")
            return
        }
        
        if let audioPlayer = audioPlayer {
            if (audioPlayer.isPlaying) {
                audioPlayer.stop()
                playBarButton.image = UIImage(named: "play")
                recordBarButton.isEnabled = true
                return
            }
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFile)
            audioPlayer?.delegate = (self as! AVAudioPlayerDelegate)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            recordBarButton.isEnabled = false
            playBarButton.image = UIImage(named: "stop")
        } catch {
            print("error creating audio player")
            return
        }
        
    }
    
    
    func initAudioRec() {
        let recordingSettings =
            [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
             AVEncoderBitRateKey: 16,
             AVNumberOfChannelsKey: 2,
             AVSampleRateKey: 44100.0] as [String : Any]
        
        guard let audioFile = audioFile else {
            print("Error, no file URL is available.")
            return
        }
        
        do {
            try audioRec = AVAudioRecorder(url: audioFile, settings: recordingSettings)
            audioRec?.delegate = (self as! AVAudioRecorderDelegate)
        } catch {
            print("Error initializing the audio recorder")
        }
    }
    
    func initFileStorage() {
        let fileManager = FileManager.default
        let documentDirectoryPaths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        docDirectoryURL = documentDirectoryPaths[0]
        audioFile = docDirectoryURL?.appendingPathComponent("audio.caf")
    }
    
    func initAudioSession() {
        audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession?.setCategory(.playAndRecord, mode: .default, options: [])
        } catch {
            print("audioSession error")
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        recordBarButton.isEnabled = true
        playBarButton.image = UIImage(named: "play")
    }
    
    
}


