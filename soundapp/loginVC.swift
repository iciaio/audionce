//
//  loginVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/16/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class loginVC: UIViewController {

    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        if let touch = touches.first as? UITouch {
            self.view.endEditing(true)
        }
        super.touchesBegan(touches , withEvent:event)
    }
    
    @IBAction func loginPressed(sender: AnyObject) {
        
        var username:NSString = txtUsername.text as NSString
        var password:NSString = txtPassword.text as NSString
        
        if (username.isEqualToString("") || password.isEqualToString("")){
            
            var alertView:UIAlertView = UIAlertView()
            alertView.title = "Sign in Failed"
            alertView.message = "Please enter Username and Password"
            alertView.delegate = self
            alertView.addButtonWithTitle("OK")
            alertView.show()
        } else {
            //check for this user in parse database!
            PFUser.logInWithUsernameInBackground("\(username)", password:"\(password)") {
                (user: PFUser?, error: NSError?) -> Void in
                if user != nil {
                    // Do stuff after successful login.
                    println("successful login!")
                    self.performSegueWithIdentifier("goto_main_from_login", sender: self)
                } else {
                    // The login failed. Check error to see why.
                    var alertView:UIAlertView = UIAlertView()
                    alertView.title = "Log in Failed"
                    alertView.message = "Incorrect username or password. Please try again."
                    alertView.delegate = self
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                }
            }
        }
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
