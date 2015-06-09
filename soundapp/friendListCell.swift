//
//  friendListCell.swift
//  soundapp
//
//  Created by Alicia Iott on 6/1/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class friendListCell: UITableViewCell {


    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    var friend = PFUser()
    var currentUser = PFUser.currentUser()
    
    @IBAction func unfriend(sender: AnyObject) {
        println("deleting friend")
        
        var query = PFUser.query()
        query!.whereKey("username", equalTo: self.userNameLabel.text!)
        query!.getFirstObjectInBackgroundWithBlock{
            (user: AnyObject?, error: NSError?) -> Void in
            if (error == nil) {
                self.friend = user as! PFUser!
                self.deleteFromEachFriendTable()
            }
            else{
                println("error querying for friend to unfriend")
                println(error)
            }
        }
    }
    
    func deleteFromEachFriendTable(){
        
        
        var currentUserFriends : PFObject = self.currentUser!["friends"] as! PFObject
        currentUserFriends.removeObject(self.friend, forKey: "all_friends")
        
        currentUserFriends.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                var friendFriends : PFObject = self.friend["friends"] as! PFObject
                friendFriends.removeObject(self.currentUser!, forKey: "all_friends")
                
                friendFriends.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        // unfriend should remove each friend from eachothers friend table and refresh friendListVC
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadFriendListVC", object: nil)
                    } else {
                        println("error deleting friends from eachothers friend table")
                    }
                }
            }
        }
    }
}
