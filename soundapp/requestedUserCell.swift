//
//  requestedUserCell.swift
//  soundapp
//
//  Created by Alicia Iott on 5/29/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class requestedUserCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    var friend = PFUser()
    
    @IBAction func recindRequest(sender: AnyObject)
    {
        println(self.userNameLabel.text!)
        var query = PFUser.query()
        query!.whereKey("username", equalTo: self.userNameLabel.text!)
        query!.getFirstObjectInBackgroundWithBlock{
            (user: AnyObject?, error: NSError?) -> Void in
            if !(error != nil) {
                self.friend = user as! PFUser!
                self.queryPending()
            }
            else{
                println("error finding friend to recind request")
                println(error)
            }
        }
    }
    
    func queryPending(){
        
        var pendingQuery = PFQuery(className:"PendingTable")
        pendingQuery.whereKey("from", equalTo: PFUser.currentUser()!)
        pendingQuery.whereKey("to", equalTo: self.friend)
        pendingQuery.findObjectsInBackgroundWithBlock {
            (requests: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                println("rescinding")
                for request in requests! {
                    request.deleteInBackground()
                }
                //rescinding a request should remove the request from pending table and refresh the addFriendVC
                NSNotificationCenter.defaultCenter().postNotificationName("reloadAddFriendVC", object: nil)
            } else {
                println("Error: \(error!) \(error!.userInfo!)")
                println("error querying pendingTable to delete request")
            }
        }
    }
}
