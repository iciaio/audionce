//
//  friendListVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/18/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

extension String {
    
    func findInString (stringToFind : String) -> Bool{
        if self != ""{
            if (self as NSString).containsString(stringToFind.lowercaseString){
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}




class addFriendVC: UITableViewController, UISearchBarDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchTextField: UISearchBar!
    var search = false
    var allUsers = [PFUser]()
    var dataSecond = [PFUser]()
    var mainData = PFUser()
    
    var incomingRequests = [PFUser]()
    var outgoingRequests = [PFUser]()
    var alreadyFriends = [PFUser]()
    let currentUser = PFUser.currentUser()
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        println("searchText \(searchText)")
        dataSecond = []
        if searchTextField.text == "" {
            search = false
            self.tableView.reloadData()
        }
        else {
            for user in allUsers{
                if (user.username! as String).lowercaseString.findInString(searchTextField.text){
                    dataSecond.append(user)
                }
            }
            search = true
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "loadList:",name:"reloadAddFriendVC", object: nil)
        searchTextField.delegate = self

        populatedPending()
        // Do any additional setup after loading the view.
    }
    
    func loadList(notification: NSNotification){
        //load data here
        populatedPending()
    }
    
    
    func populatedPending(){
        
        self.incomingRequests = []
        var requestQuery = PFQuery(className:"PendingTable")
        requestQuery.whereKey("to", equalTo: self.currentUser!)
        requestQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) requests.")
                for request in objects!{
                    self.incomingRequests.append(request["from"] as! PFUser)
                }
                self.populateRequested()
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    func populateRequested() { //requests that YOU have sent to users
        
        self.outgoingRequests = []
        var pendingQuery = PFQuery(className:"PendingTable")
        pendingQuery.whereKey("from", equalTo: self.currentUser!)
        pendingQuery.findObjectsInBackgroundWithBlock {
            (objects: [AnyObject]?, error: NSError?) -> Void in
            
            if error == nil {
                // The find succeeded.
                println("Successfully retrieved \(objects!.count) requests.")
                for request in objects!{
                    self.outgoingRequests.append(request["to"] as! PFUser)
                }
                self.populateAlreadyFriends()
            } else {
                // Log details of the failure
                println("Error: \(error!) \(error!.userInfo!)")
            }
        }
    }
    
    func populateAlreadyFriends(){
        var friends = self.currentUser?["friends"] as! PFObject
        friends.fetchIfNeededInBackgroundWithBlock({
            (object, error) -> Void in
            if (error == nil){
                self.alreadyFriends = friends["all_friends"]! as! [PFUser]
                self.populateUnrelatedUsers()
            } else {
                println("error getting people already friends for search view")
            }
        })
    }
    
    func populateUnrelatedUsers() { //These users will show up in search
        
        self.allUsers = []
        var query = PFUser.query()
        query!.findObjectsInBackgroundWithBlock {
            (users: [AnyObject]?, error: NSError?) -> Void in
            if !(error != nil) {
                for user in users!{
                    if (user.username != self.currentUser?.username) &&
                        (!contains (self.incomingRequests, user as! PFUser)) &&
                        (!contains (self.outgoingRequests, user as! PFUser)) &&
                        (!contains (self.alreadyFriends, user as! PFUser)){
                        self.allUsers.append(user as! PFUser)
                    }
                }
                self.tableView.reloadData()
            }
            else{
                println(error)
            }
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if search == true{
            if dataSecond != [] {
                mainData = (dataSecond[indexPath.row])
            }
            var cell = self.tableView.dequeueReusableCellWithIdentifier("Cell1", forIndexPath: indexPath) as! userCell
            mainData.fetchIfNeededInBackgroundWithBlock({
                (object, error) -> Void in
                if (error == nil){
                    if let name = self.mainData.username{
                        cell.userNameLabel.text = self.mainData.username
                    }
                }
            })
            return cell
        }
        else{
            if (indexPath.section == 0) {
                println(incomingRequests.count)
                println(indexPath.row)
                mainData = incomingRequests[indexPath.row]
                var cell2 = self.tableView.dequeueReusableCellWithIdentifier("Cell2", forIndexPath: indexPath) as! myRequestedUserCell
                mainData.fetchIfNeededInBackgroundWithBlock({
                    (object, error) -> Void in
                    if (error == nil){
                        if let name = self.mainData.username{
                            cell2.userNameLabel.text = self.mainData.username
                        }
                    }
                })
                return cell2
            } else {
                println(incomingRequests.count)
                println(indexPath.row)
                mainData = outgoingRequests[indexPath.row]
                var cell3 = self.tableView.dequeueReusableCellWithIdentifier("Cell3", forIndexPath: indexPath) as! requestedUserCell
                mainData.fetchIfNeededInBackgroundWithBlock({
                    (object, error) -> Void in
                    if (error == nil){
                        if let name = self.mainData.username{
                            cell3.userNameLabel.text = self.mainData.username
                        }
                    }
                })
                return cell3
            }
        }
    }
    
    override func numberOfSectionsInTableView(tableView : UITableView) -> Int{
        if search == true {
            return 1
        } else{
            return 2
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfCellsToReturn = 0
        if search == true {
            numberOfCellsToReturn = dataSecond.count
        }
        else{
            if section == 0{
                println("here")
                println(self.incomingRequests.count)
                numberOfCellsToReturn = self.incomingRequests.count
            }
            else if section == 1{
                numberOfCellsToReturn = self.outgoingRequests.count
            }
        }
        return numberOfCellsToReturn
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (search == true) {
            return nil
        } else {
            if (section == 0){
                if self.incomingRequests.count == 0 {
                    return nil
                }else {
                    return "Requests to me"
                }
            }
            else {
                if self.outgoingRequests.count == 0 {
                    return nil
                }else {
                    return "Requests from me"
                }
            }
        }
        
    }

}
