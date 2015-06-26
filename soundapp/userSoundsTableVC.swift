//
//  friendListVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/18/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class userSoundsTableVC: UITableViewController {
    
    var currentUser = PFUser.currentUser()
    var soundArray = [PFObject]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"reloadFriendListVC", object: nil)
        self.setSounds()
    }
    
    func setSounds(){
        self.soundArray = []
        if let sounds = self.currentUser!["sounds"] as? [PFObject]{
            for sound in sounds {
                sound.fetchIfNeededInBackgroundWithBlock({
                    (object, error) -> Void in
                    if (error == nil){
                        self.soundArray.append(sound)
                        self.tableView.reloadData()
                    }
                })
            }
        }
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.setSounds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println(self.soundArray.count)
        return self.soundArray.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("cell4", forIndexPath: indexPath) as! soundCell
        
        cell.soundTitle.text = self.soundArray[indexPath.row]["title"]! as? String
        cell.soundId = self.soundArray[indexPath.row].objectId!
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            
            var soundObject = soundArray[indexPath.row] as PFObject
            
            self.soundArray.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            
//            currentUser!["sounds"] = soundArray
            
//            if ((soundObject["is_private"] as! Bool) == true) {
//                if let toUsers = soundObject["to"] as? [PFUser]{
//                    for user in toUsers{
//                        user.fetchIfNeededInBackgroundWithBlock({
//                            (object, error) -> Void in
//                            if (error == nil){
//                                var sharedSoundsQuery = PFQuery(className:"SharedSounds")
//                                sharedSoundsQuery.whereKey("user", equalTo: user)
//                                sharedSoundsQuery.getFirstObjectInBackgroundWithBlock{
//                                    (sharedSound: AnyObject?, error: NSError?) -> Void in
//                                    if !(error != nil) {
//                                        if let sharedSound = sharedSound as? PFObject!{
//                                            if let soundArray = sharedSound["sounds"] as? [PFObject]!{
//                                                let index = find(soundArray, soundObject)
//                                                soundArray.removeAtIndex(index)
//                                            }
//                                        }
//                                    }
//                                    else{
//                                        println("error getting shared sounds for deletion\(error)")
//                                    }
//                                }
//
//                            }
//                        })
//                    }
//                }
//            }
            
            soundObject.deleteInBackground()
            currentUser?.saveInBackground()

        }
    }
}