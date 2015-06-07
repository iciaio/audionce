//
//  soundCell.swift
//  soundapp
//
//  Created by Alicia Iott on 6/7/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit

class soundCell: UITableViewCell {
    
    @IBOutlet weak var soundTitle: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    var soundId : String = "fuck"
    
    @IBAction func playPauseButton(sender: AnyObject) {
        println("hi")
    }
    
}
