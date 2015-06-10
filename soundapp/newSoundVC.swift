//
//  loginVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/16/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse
import AVFoundation
import CoreGraphics

class newSoundVC: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    

    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var recordStopButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var titleTextField: UITextField!
    
    var player: AVAudioPlayer!
    var recorder: AVAudioRecorder!
    var soundFileURL = NSURL()
    var soundFilePath = ""
    var meterTimer:NSTimer!
    var shareWithUserNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateUserArray:",name:"userArrayUpdate", object: nil)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 22))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "navaddsound.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        recordStopButton.setTitle("Record", forState: UIControlState.Normal)
        playPauseButton.setTitle("Play", forState: UIControlState.Normal)
        playPauseButton.enabled = false
        submitButton.enabled = false
        setSessionPlayback()
    }
    
    func updateUserArray(notification:NSNotification) {
        let userInfo:Dictionary<String,[String]!> = notification.userInfo as! Dictionary<String,[String]!>
        println("heyooo")
//        if let userArray = userInfo["userArray"]! {
//            self.shareWithUserNames = userArray
//        }
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func setSessionPlayback() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayback, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordStopAudio(sender: AnyObject) {
        if player != nil && player.playing { //if player is playing, stop it
            player.stop()
        }
        
        if recorder == nil { //BEGIN RECORDING
            println("recording. recorder nil")
            submitButton.enabled = false
            var stop = UIImage(named: "stoprecording.png") as UIImage!
            recordStopButton.setImage(stop, forState: UIControlState.Normal)
            //recordStopButton.setTitle("Stop", forState:.Normal)
            playPauseButton.enabled = false
            recordWithPermission(true)
            return
        }
        
        if recorder != nil && recorder.recording { //STOP RECORDING
            println("stopping")
            recorder.stop()
            playPauseButton.enabled = true
            submitButton.enabled = false
            var recording = UIImage(named: "recording") as UIImage!
            recordStopButton.setImage(recording, forState: UIControlState.Normal)
            //recordStopButton.setTitle("Record", forState:.Normal)
            let session:AVAudioSession = AVAudioSession.sharedInstance()
            var error: NSError?
            if !session.setActive(false, error: &error) {
                println("could not make session inactive")
                if let e = error {
                    println(e.localizedDescription)
                    return
                }
            }
            recorder = nil
            player = nil
            submitButton.enabled = true
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        println("playing")
        if player != nil && player.playing { //STOP PLAYBACK
            println("pausing")
            var play = UIImage(named: "playaudio.png") as UIImage!
            playPauseButton.setImage(play, forState: UIControlState.Normal)
            //playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            player.pause()
            
        } else { //PLAYBACK
            println("playing")
            var pause = UIImage(named: "pauseaudio.png") as UIImage!
            playPauseButton.setImage(pause, forState: UIControlState.Normal)
            //playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
            
            if player == nil {
                var error: NSError?
                
                self.player = AVAudioPlayer(contentsOfURL: soundFileURL, error: &error)
                if player == nil {
                    if let e = error {
                        println(e.localizedDescription)
                    }
                }
                player.delegate = self
                player.prepareToPlay()
                player.volume = 1.0
                player.play()
            } else {
                player.play()
            }
        }
    }

    @IBAction func submitAudio(sender: AnyObject) {
        var error: NSError?
        
        if (self.titleTextField.text == ""){
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "No title"
            alertView.message = "Please enter a title for your sound."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            let fileData = NSData(contentsOfURL: soundFileURL)
            let parseFile = PFFile(name: "sound.aac", data: fileData!)
            parseFile.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    var newSound = PFObject(className: "Sounds")
                    PFGeoPoint.geoPointForCurrentLocationInBackground {
                        (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
                        if error == nil {
                            newSound["file"] = parseFile
                            newSound["title"] = self.titleTextField.text
                            newSound["location"] = geoPoint
                            newSound["user"] = PFUser.currentUser()
                            newSound.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    println("submit pressed")
                                    self.player = nil
                                    self.recorder = nil
                                    self.playPauseButton.enabled = false
                                    self.submitButton.enabled = false
                                    self.titleTextField.text = ""
                                    self.addToUserSoundArray(newSound)
                                    self.makeSoundVisibleToUsers(newSound)
                                    self.deleteNearbySounds(geoPoint!, soundId: newSound.objectId!)
                                    self.performSegueWithIdentifier("to_main_from_submit", sender: self)
                                } else {
                                    println("error saving sound")
                                }
                            }
                        }
                    }
                } else {
                    println("error saving file")
                }
            }
        }
    }
    
    func makeSoundVisibleToUsers(soundObject: PFObject){
        println("making sound visible to other users")
    }
    
    func deleteNearbySounds(userGeoPoint: PFGeoPoint, soundId: String) {
        var soundQuery = PFQuery(className:"Sounds")
        soundQuery.whereKey("location", nearGeoPoint:userGeoPoint)
        soundQuery.findObjectsInBackgroundWithBlock {(sounds: [AnyObject]?, error: NSError?) -> Void in
            if (error == nil){
                for sound in sounds as! [PFObject]{
                    let nearbySoundPoint = sound["location"] as! PFGeoPoint
                    if (userGeoPoint.distanceInKilometersTo(nearbySoundPoint) < 0.030) &&
                        (sound.objectId! != soundId) {
                            
                            var alertView:UIAlertView = UIAlertView()
                            alertView.title = "Overwriting nearby sound."
                            alertView.message = "We're just making room for you!:)"
                            alertView.delegate = self
                            alertView.addButtonWithTitle("OK")
                            alertView.show()
                            
                            sound.deleteInBackground()
                    }
                }
            }
        }
    }

    //faith is when you belive something determines the undeterminable, not that everything is inherently determinable (though perhaps not by us). the latter is science

    func addToUserSoundArray(soundObject : PFObject){
        println("3")
        let currentUser = PFUser.currentUser()
        currentUser!.addObject(soundObject, forKey: "sounds")
        currentUser!.saveInBackground()
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }

    func setSessionPlayAndRecord() {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        var error: NSError?
        if !session.setCategory(AVAudioSessionCategoryPlayAndRecord, error:&error) {
            println("could not set session category")
            if let e = error {
                println(e.localizedDescription)
            }
        }
        if !session.setActive(true, error: &error) {
            println("could not make session active")
            if let e = error {
                println(e.localizedDescription)
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        //playPauseButton.setTitle("Play", forState: UIControlState.Normal)
        var play = UIImage(named: "playaudio.png") as UIImage!
        playPauseButton.setImage(play, forState: UIControlState.Normal)
    }
    
    func recordWithPermission(setup:Bool) {
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        // ios 8 and later
        if (session.respondsToSelector("requestRecordPermission:")) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    println("Permission to record granted")
                    self.setSessionPlayAndRecord()
                    if setup {
                        self.setupRecorder()
                    }
                    println("about to record...")
                    self.recorder.record()
                    println("recording now")
//                    println("about to meter")
//                    self.meterTimer = NSTimer.scheduledTimerWithTimeInterval(0.1,
//                        target:self,
//                        selector:"updateAudioMeter:",
//                        userInfo:nil,
//                        repeats:true)
//                    
                } else {
                    println("Permission to record not granted")
                }
            })
        } else {
            println("requestRecordPermission unrecognized")
        }
    }
    
    func setupRecorder() {
        println("setting up recorder")
        var format = NSDateFormatter()
        format.dateFormat="yyyy-MM-dd-HH-mm-ss"
        var currentFileName = "recording-\(format.stringFromDate(NSDate())).m4a"
        println(currentFileName)
        
        var dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        var docsDir: AnyObject = dirPaths[0]
        var soundFilePath = docsDir.stringByAppendingPathComponent(currentFileName)
        soundFileURL = NSURL(fileURLWithPath: soundFilePath)!
        
        var recordSettings:[NSObject: AnyObject] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVEncoderAudioQualityKey : AVAudioQuality.Max.rawValue,
            AVEncoderBitRateKey : 320000,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey : 44100.0
        ]
        var error: NSError?
        recorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings, error: &error)
        if let e = error {
            println(e.localizedDescription)
        } else {
            recorder.delegate = self
            recorder.meteringEnabled = true
            recorder.prepareToRecord() // creates/overwrites the file at soundFileURL
            println("end of setuprecorder")
        }
    }

}
