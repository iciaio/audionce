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
                        var audioFile: PFFile = sound!["file"] as! PFFile
                        audioFile.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                            if (error == nil) {
                                let audioURLString = audioFile.url!
                                let audioURL = NSURL(string: audioURLString)!
                                println(audioURL)
                                let audioData = NSData(contentsOfURL: audioURL)!
                                println(audioData)
                                let player = AVAudioPlayer(data: audioData, error: nil)
                                println(player)
                                player.play()
                            }
                        }
                    }
                })
            }
        }
    }
    
}
