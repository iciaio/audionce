//
//  friendListVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/18/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class friendListVC: UITableViewController {
    
    var currentUser = PFUser.currentUser()
    var friendArray = [PFUser]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 110, height: 22))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "friendsnav.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"reloadFriendListVC", object: nil)
        self.setFriends()
    }
    
    func setFriends(){
        if let currentUserFriends = self.currentUser?["friends"] as? PFObject{
            var friends = currentUserFriends
            friends.fetchIfNeededInBackgroundWithBlock({
                (object, error) -> Void in
                if (error == nil){
                    self.friendArray = friends["all_friends"]! as! [PFUser]
                    println(self.friendArray.count)
                    
                    self.tableView.reloadData()
                }
            })
        }
    }
    
    func loadList(notification: NSNotification){
        //load data here
        self.setFriends()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! friendListCell
        
        friendArray[indexPath.row].fetchIfNeededInBackgroundWithBlock({
            (object, error) -> Void in
            if (error == nil){
                cell.userNameLabel.text = self.friendArray[indexPath.row].username
                cell.userImage.layer.cornerRadius = cell.userImage.frame.size.width/2
                cell.userImage.clipsToBounds = true
                if let userPicture = self.friendArray[indexPath.row]["profile_picture"] as? PFFile {
                    userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            cell.userImage.image = UIImage(data:imageData!)
                        }
                    }
                }
            }
        })

        //println(friendArray[indexPath.row].username)
        return cell
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
