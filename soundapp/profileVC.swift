//
//  profileVC.swift
//  navigating
//
//  Created by Alicia Iott on 5/16/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse

class profileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var profilePicture: UIImageView!
    @IBOutlet weak var editNameOutlet: UIButton!
    @IBOutlet weak var editPicOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let editImage = UIImage(named: "editpencil.png")
        self.editNameOutlet.setImage(editImage, forState: UIControlState.Normal)
        self.editPicOutlet.setImage(editImage, forState: UIControlState.Normal)

        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 67, height: 22))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "navprofile.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width/2
        self.profilePicture.clipsToBounds = true
        if let userPicture = PFUser.currentUser()?["profile_picture"] as? PFFile {
            userPicture.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if (error == nil) {
                    self.profilePicture.image = UIImage(data:imageData!)
                }
            }
        }
                
        self.txtUsername.text = PFUser.currentUser()?.username
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> Int {
        return Int(UIInterfaceOrientation.Portrait.rawValue)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func editUsername(sender: AnyObject) {
        displayNewUsernameAlert()
    }
    
    @IBAction func editProfilePicture(sender: AnyObject) {
        displayNewProfilePictureAlert()
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!){
        let user = PFUser.currentUser()
        self.profilePicture.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
        
        let imageData = UIImagePNGRepresentation(image)
        let imageFile = PFFile(data:imageData)
        
        user?["profile_picture"] = imageFile
        user?.saveInBackground()
    }
    
    @IBAction func logoutPressed(sender: UIButton) {
        PFUser.logOut()
        var currentUser = PFUser.currentUser()
        self.performSegueWithIdentifier("goto_login", sender: self)
    }

    func displayNewUsernameAlert(){
        //format alert to change username
        let alert = UIAlertController(title: "Username", message: "Enter a new username. Note: this is the username you login with.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            if let textField: UITextField = alert.textFields?.first as? UITextField{
                if (count(textField.text) > 0){
                    var currentUser = PFUser.currentUser()
                    currentUser!.username = textField.text
                    currentUser!.save()
                    self.txtUsername.text = PFUser.currentUser()?.username
                }
            }
        })
        alert.addAction(ok)
        
        alert.addTextFieldWithConfigurationHandler({(textField) -> Void in
            textField.placeholder = "Username"})
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayNewProfilePictureAlert(){
        let alert = UIAlertController(title: "Profile Picture", message: "Take or upload a new photo.", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let upload = UIAlertAction(title: "Upload", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .PhotoLibrary
            self.presentViewController(picker, animated: true, completion: nil)
        })
        alert.addAction(upload)
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: {(action) -> Void in
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .Camera
            self.presentViewController(picker, animated: true, completion: nil)
        })
        alert.addAction(takePhoto)
        
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alert.addAction(cancel)
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
}

