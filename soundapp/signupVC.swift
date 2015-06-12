//
//  signupVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/16/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class signupVC: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red:199.0/255.0, green:190.0/255.0, blue:216.0/255.0, alpha:1.0)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signupPressed(sender: AnyObject) {
        var username = txtUsername.text
        var password = txtPassword.text
        var confirm_password = txtConfirmPassword.text
        
        if (count(username) == 0 || count(password) == 0){
        
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign up failed"
            alertView.message = "Please enter a Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else if (!password.isEqual(confirm_password)) {
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign up failed"
            alertView.message = "Oops! Passwords don't match."
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            //add this user to parse database!
            var user = PFUser()
            
            //a user will have a
            // username
            // password
            // profile picture
            // soundlist (this is a list of sound objects)
            // friendlist
            
            //a sound will have
            // location
            // file
            // title
            
            user.username = username
            user.password = password
            
            let image = UIImage(named: "me.jpg")
            let imageData = UIImagePNGRepresentation(image)
            let imageFile = PFFile(data:imageData)
            
            user["profile_picture"] = imageFile
            
            user.signUpInBackgroundWithBlock {
                (succeeded: Bool, error: NSError?) -> Void in
                if let error = error {
                    let errorString = error.userInfo?["error"] as? NSString
                    println("\(errorString)")
                    
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Sign up Error"
                    alertView.message = "\(errorString)"
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                
                } else{
                    //go to main view
                    //keep user logged in
                    var friendTable = PFObject(className: "FriendTable")
                    friendTable["user"] = PFUser.currentUser()
                    friendTable["all_friends"] = NSMutableArray()
                    friendTable.saveInBackgroundWithBlock {
                        (success: Bool, error: NSError?) -> Void in
                        if (success) {
                            var soundList: [PFObject] = []
                            var sharedSounds: [PFObject] = []
                            var pointerToSharedSoundsObject = PFObject(className: "SharedSounds")
                            pointerToSharedSoundsObject["user"] = PFUser.currentUser()
                            pointerToSharedSoundsObject["sounds"] = []
                            pointerToSharedSoundsObject.saveInBackgroundWithBlock {
                                (success: Bool, error: NSError?) -> Void in
                                if (success) {
                                    user["sounds"] = soundList
                                    user["friends"] = friendTable
                                    user["observable_sounds"] = sharedSounds
                                    user["shared_sounds"] = pointerToSharedSoundsObject
                                    user.saveInBackground()
                                    
                                    self.performSegueWithIdentifier("to_main_from_signup", sender: self)
                                } else {
                                    println("failed to create pointer to shared sounds")
                                }
                            }
                        } else {
                            println("signup failed!")
                        }
                    }
                    
                }
            }
        }
        
        
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    @IBAction func gotoLogin(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
