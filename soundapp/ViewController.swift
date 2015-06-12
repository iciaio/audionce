//
//  ViewController.swift
//  navigating
//
//  Created by Alicia Iott on 5/16/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import UIKit
import Parse
import MapKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, MKMapViewDelegate, AVAudioPlayerDelegate   {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var currentLocation = CLLocationCoordinate2D()
    var oldAnnotationDict = Dictionary<String, MKAnnotation>()
    var newAnnotationDict = Dictionary<String, MKAnnotation>()
    var player : AVAudioPlayer!
    var geoSounds : [PFObject] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        if (PFUser.currentUser() == nil){
            self.performSegueWithIdentifier("goto_login", sender: self)
        } else {
        
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 22))
            imageView.contentMode = .ScaleAspectFit
            let image = UIImage(named: "navaudionce.png")
            imageView.image = image
            navigationItem.titleView = imageView
            
            var timer = NSTimer.scheduledTimerWithTimeInterval(60.0, target: self, selector: Selector("clearAndRepopulateAnnotations"), userInfo: nil, repeats: true)
            locationManager = CLLocationManager()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest;
            locationManager.requestAlwaysAuthorization()
            locationManager.distanceFilter = 1.0;
            mapView.showsUserLocation = true
            mapView.delegate = self
            locationManager.startUpdatingLocation()
            var locValue:CLLocationCoordinate2D = locationManager.location.coordinate
            println(locationManager.location)
            mapView.setRegion(MKCoordinateRegionMakeWithDistance(locValue, 400, 400), animated: true)
            queryForAnnotations()
        }
    }
    
    func clearAndRepopulateAnnotations(){
        queryForAnnotations()
    }
    
    func queryForAnnotations() {
        self.geoSounds = []
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (userGeoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                
                var soundQuery = PFQuery(className:"Sounds")
                soundQuery.whereKey("location", nearGeoPoint:userGeoPoint!)
                soundQuery.findObjectsInBackgroundWithBlock {
                    (sounds: [AnyObject]?, error: NSError?) -> Void in

                    if error == nil {

                        // The find succeeded.
                        for sound in sounds!{
                            if (sound["is_private"] as! Bool == false) || (contains(sound["to"] as! [PFUser], PFUser.currentUser()!)) { //if the sound is public or private and the user can see it
                                let identifier = sound.objectId! as String!
                                if self.oldAnnotationDict[identifier] != nil {
                                    self.newAnnotationDict[identifier] = self.oldAnnotationDict[identifier]
                                } else {
                                    //Make annotation.
                                    let titleString = sound["title"]! as! String
                                    let loc = sound["location"]! as! PFGeoPoint
                                    let soundAnnotation = Sound(title: titleString,
                                        locationName: "some location",
                                        discipline: "public",
                                        coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
                                    self.newAnnotationDict[identifier] = soundAnnotation
                                    self.mapView.addAnnotation(soundAnnotation)
                                }
                                self.geoSounds.append(sound as! PFObject)
                            }
                        }
                        for (identifier, soundAnnotation) in self.oldAnnotationDict {
                            if (self.newAnnotationDict[identifier] == nil) {
                                self.mapView.removeAnnotation(soundAnnotation as MKAnnotation)
                            }
                        }
                        self.oldAnnotationDict = self.newAnnotationDict
                        self.newAnnotationDict = [:]
                    } else {
                        // Log details of the failure
                        println("Error: \(error!) \(error!.userInfo!)")
                    }
                }
            }
        }
    }
    
    func playClosestSound(){
        println("playing closest sound")
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                for sound in self.geoSounds{
                    let loc = sound["location"] as! PFGeoPoint
                    let audioFile: PFFile = sound["file"] as! PFFile
                    if (loc.distanceInKilometersTo(geoPoint) < 0.02){
                        audioFile.getDataInBackgroundWithBlock({
                            (soundData: NSData?, error: NSError?) -> Void in
                            if (error == nil) {

                                dispatch_async(dispatch_get_main_queue()) {
                                    self.player = AVAudioPlayer(data: soundData!, error: nil)
                                    self.player.delegate = self
                                    self.player.play()
                                    return
                                    
                                }

                            } else {
                                println("error")
                            }
                        })
                    }
                }
            }
        }
    }

    func mapView(mapView: MKMapView!, didUpdateUserLocation userLocation: MKUserLocation!) {
        currentLocation = CLLocationCoordinate2DMake(userLocation.coordinate.latitude, userLocation.coordinate.longitude)
        println("updating location")
        if (self.player == nil){
            playClosestSound()
        } else { //if player is not nil, a sound is playing so do not update location
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        self.player = nil
        self.locationManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}



//
//                var soundQuery = PFQuery(className:"Sounds")
//                soundQuery.whereKey("location", nearGeoPoint:userGeoPoint!)
//                soundQuery.findObjectsInBackgroundWithBlock {
//                    (sounds: [AnyObject]?, error: NSError?) -> Void in
//                    
//                    if error == nil {
//                        
//                        // The find succeeded.
//                        for sound in sounds!{
//
//                            let identifier = sound.objectId! as String!
//                            if self.oldAnnotationDict[identifier] != nil {
//                                self.newAnnotationDict[identifier] = self.oldAnnotationDict[identifier]
//                            } else {
//                                //Make annotation.
//                                let titleString = sound["title"]! as! String
//                                let loc = sound["location"]! as! PFGeoPoint
//                                let soundAnnotation = Sound(title: titleString,
//                                    locationName: "some location",
//                                    discipline: "public",
//                                    coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude))
//                                self.newAnnotationDict[identifier] = soundAnnotation
//                                self.mapView.addAnnotation(soundAnnotation)
//                            }
//                        }
//                        for (identifier, soundAnnotation) in self.oldAnnotationDict {
//                            if (self.newAnnotationDict[identifier] == nil) {
//                                self.mapView.removeAnnotation(soundAnnotation as MKAnnotation)
//                            }
//                        }
//                        self.oldAnnotationDict = self.newAnnotationDict
//                        self.newAnnotationDict = [:]
//                    } else {
//                        // Log details of the failure
//                        println("Error: \(error!) \(error!.userInfo!)")
//                    }
//                }
//            }
    
//    func getClosestSound() {
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (userGeoPoint: PFGeoPoint?, error: NSError?) -> Void in
//            if error == nil {
//                var soundQuery = PFQuery(className:"Sounds")
//                soundQuery.whereKey("location", nearGeoPoint:userGeoPoint!)
//                soundQuery.limit = 1
//                soundQuery.getFirstObjectInBackgroundWithBlock {
//                    (sound: PFObject?, error: NSError?) -> Void in
//                    if error != nil || sound == nil {
//                    } else {
//
//                        let audioFile: PFFile = sound!["file"] as! PFFile
//                        let loc = sound!["location"] as! PFGeoPoint
//
//                        //want to check if sound!["location"] is close enough to userlocation
//
//                        if (userGeoPoint!.distanceInKilometersTo(loc) < 0.02) { //this is 20 meters
//                            audioFile.getDataInBackgroundWithBlock({
//                                (soundData: NSData?, error: NSError?) -> Void in
//                                if (error == nil) {
//
//                                    dispatch_async(dispatch_get_main_queue()) {
//                                        self.player = AVAudioPlayer(data: soundData!, error: nil)
//                                        self.player.delegate = self
//                                        self.player.play()
//                                    }
//
//                                } else {
//                                    println("error")
//                                }
//                            })
//                        }
//                    }
//                }
//            }
//        }
//    }
    
//        PFGeoPoint.geoPointForCurrentLocationInBackground {
//            (userGeoPoint: PFGeoPoint?, error: NSError?) -> Void in
//            if error == nil {
//                var soundQuery = PFQuery(className:"Sounds")
//                soundQuery.whereKey("location", nearGeoPoint:userGeoPoint!)
//                soundQuery.limit = 1
//                soundQuery.getFirstObjectInBackgroundWithBlock {
//                    (sound: PFObject?, error: NSError?) -> Void in
//                    if error != nil || sound == nil {
//                    } else {
//                        
//                        let audioFile: PFFile = sound!["file"] as! PFFile
//                        let loc = sound!["location"] as! PFGeoPoint
//                        
//                        //want to check if sound!["location"] is close enough to userlocation
//
//                        if (userGeoPoint!.distanceInKilometersTo(loc) < 0.02) { //this is 20 meters
//                            audioFile.getDataInBackgroundWithBlock({
//                                (soundData: NSData?, error: NSError?) -> Void in
//                                if (error == nil) {
//                                    
//                                    dispatch_async(dispatch_get_main_queue()) {
//                                        self.player = AVAudioPlayer(data: soundData!, error: nil)
//                                        self.player.delegate = self
//                                        self.player.play()
//                                    }
//                                    
//                                } else {
//                                    println("error")
//                                }
//                            })
//                        
//                        }
//                        
//                    }
//                }
//            }
//        }

    


