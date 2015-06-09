//
//  chooseFriendsVC.swift
//  soundapp
//
//  Created by Alicia Iott on 6/9/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

let reuseIdentifier = "chooseCell"

class chooseFriendsVC: UICollectionViewController {
    
    var currentUser = PFUser.currentUser()
    var friendArray = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "chooseFriendsCell")
        self.setFriends()

        // Do any additional setup after loading the view.
    }
    
    func setFriends(){
        println("setting friends")
        var friends = self.currentUser?["friends"] as! PFObject
        friends.fetchIfNeededInBackgroundWithBlock({
            (object, error) -> Void in
            if (error == nil){
                self.friendArray = friends["all_friends"]! as! [PFUser]
                println(self.friendArray.count)
                
                self.collectionView?.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        //#warning Incomplete method implementation -- Return the number of sections
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //#warning Incomplete method implementation -- Return the number of items in the section
        return self.friendArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("friendCell", forIndexPath: indexPath) as! chooseFriendsCell
        
        friendArray[indexPath.row].fetchIfNeededInBackgroundWithBlock({
            (object, error) -> Void in
            if (error == nil){
                cell.userNameLabel.text = self.friendArray[indexPath.row].username
                cell.userPicture.layer.cornerRadius = cell.userPicture.frame.size.width/2
                cell.userPicture.clipsToBounds = true
                if let userPicture = self.friendArray[indexPath.row]["profile_picture"] as? PFFile {
                    userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if (error == nil) {
                            cell.userPicture.image = UIImage(data:imageData!)
                        }
                    }
                }
            }
        })
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

}
