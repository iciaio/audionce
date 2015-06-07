//
//  soundCell.swift
//  soundapp
//
//  Created by Alicia Iott on 6/7/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse
import AVFoundation

class soundCell: UITableViewCell, AVAudioPlayerDelegate {
    
    @IBOutlet weak var soundTitle: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    var soundId : String = ""
    
    @IBAction func playPauseButton(sender: AnyObject) {
        println(soundId)
        var query = PFQuery(className: "Sounds")
        query.whereKey("objectId", equalTo: soundId)
        query.getFirstObjectInBackgroundWithBlock{
            (sound: PFObject?, error: NSError?) -> Void in
            if error != nil || sound == nil {
                println("request user failed on getting friend to request")
            } else {
                // The find succeeded.
                sound?.fetchIfNeededInBackgroundWithBlock({
                    (object, error) -> Void in
                    if (error == nil){
//                        var error: NSError?
//                        var audioFile: PFFile = sound!["file"] as! PFFile
//                        var audioURLString = audioFile.url!
//                        let audioURL = NSURL(fileURLWithPath: audioURLString)
//                        let soundData = NSData(contentsOfURL: audioURL!)
//                        println("playing.... (or at least it should be")
//                        var player = AVAudioPlayer(data: soundData, error: &error)
//                        if player == nil {
//                            if let e = error {
//                                println(e.localizedDescription)
//                            }
//                        }
//                        player.prepareToPlay()
//                        player.volume = 1.0
//                        player.delegate = self
//                        player.play()
                        println("here")
                    }
                })
            }
        }
    }
    
}
