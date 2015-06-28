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
    var player: AVAudioPlayer!
    
    @IBAction func playPauseButton(sender: AnyObject) {
        
        if player != nil && player.playing { //STOP PLAYBACK
            self.playPauseButton.setTitle("Play", forState: UIControlState.Normal)
            self.player.pause()
            
        } else { //PLAYBACK
            playPauseButton.setTitle("Pause", forState: UIControlState.Normal)
    
            if self.player == nil {
                var query = PFQuery(className: "Sounds")
                query.whereKey("objectId", equalTo: soundId)
                query.getFirstObjectInBackgroundWithBlock{
                    (sound: PFObject?, error: NSError?) -> Void in
                    if error != nil || sound == nil {
                    } else {
                        // The find succeeded.
                        sound?.fetchIfNeededInBackgroundWithBlock({
                            (object, error) -> Void in
                            if (error == nil){
                                var audioFile: PFFile = sound!["file"] as! PFFile
                                audioFile.getDataInBackgroundWithBlock { (audioData: NSData?, error: NSError?) -> Void in
                                    if (error == nil) {
                                        dispatch_async(dispatch_get_main_queue()) {
                                            self.player = AVAudioPlayer(data: audioData, error: nil)
                                            self.player.delegate = self
                                            self.player.volume = 2.0
                                            self.player.play()
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            } else {
                self.player.play()
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.playPauseButton.setTitle("Play", forState: UIControlState.Normal)
    }
    
}
