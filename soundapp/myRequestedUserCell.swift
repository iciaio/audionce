//
//  myRequestedUserCell.swift
//  soundapp
//
//  Created by Alicia Iott on 5/29/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class myRequestedUserCell: UITableViewCell {
    
    let currentUser = PFUser.currentUser()
    var friend = PFUser()
    
    
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBAction func acceptRequest(sender: AnyObject) {
        
        var query = PFUser.query()
        query!.whereKey("username", equalTo: self.userNameLabel.text!)
        query!.getFirstObjectInBackgroundWithBlock{
            (user: AnyObject?, error: NSError?) -> Void in
            if !(error != nil) {
                self.friend = user as! PFUser!
                self.queryPending()
            }
            else{
                println("error querying for user to accept request")
                println(error)
            }
        }
        
    }
    
    func queryPending(){
        
        var pendingQuery = PFQuery(className:"PendingTable")
        pendingQuery.whereKey("to", equalTo: PFUser.currentUser()!)
        pendingQuery.whereKey("from", equalTo: self.friend)
        pendingQuery.findObjectsInBackgroundWithBlock {
            (requests: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                for request in requests! {
                    request.deleteInBackground()
                }
                self.addToEachFriendsTable()
            } else {
                println("error querying pendingTable to remove pending request")
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
        
    }
    
    func addToEachFriendsTable(){
                
        
        var currentUserFriends : PFObject = self.currentUser!["friends"] as! PFObject
        currentUserFriends.addObject(self.friend, forKey: "all_friends")
        
        currentUserFriends.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                
                var friendFriends : PFObject = self.friend["friends"] as! PFObject
                friendFriends.addObject(self.currentUser!, forKey: "all_friends")
                
                friendFriends.saveInBackgroundWithBlock {
                    (success: Bool, error: NSError?) -> Void in
                    if (success) {
                        //should reload addFriendsVC and also friendListVC
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadAddFriendVC", object: nil)
                        NSNotificationCenter.defaultCenter().postNotificationName("reloadFriendListVC", object: nil)                        
                    } else {
                        println("error adding friend to eachothers friend table")
                    }
                }
            } else {
                println("error adding friend to eachothers friend table")
            }
        }
    }
    
}
