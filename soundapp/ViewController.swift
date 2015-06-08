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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 85, height: 22))
        imageView.contentMode = .ScaleAspectFit
        let image = UIImage(named: "navaudionce.png")
        imageView.image = image
        navigationItem.titleView = imageView
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: Selector("clearAndRepopulateAnnotations"), userInfo: nil, repeats: true)
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
        getClosestSound()
    }
    
    func clearAndRepopulateAnnotations(){
        queryForAnnotations()
    }
    
    func queryForAnnotations() {
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
    
    func getClosestSound() {
        //println("finding closest sound")
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (userGeoPoint: PFGeoPoint?, error: NSError?) -> Void in
            if error == nil {
                var soundQuery = PFQuery(className:"Sounds")
                soundQuery.whereKey("location", nearGeoPoint:userGeoPoint!)
                soundQuery.limit = 1
                soundQuery.getFirstObjectInBackgroundWithBlock {
                    (sound: PFObject?, error: NSError?) -> Void in
                    if error != nil || sound == nil {
                        println("The getClosestSound request failed.")
                    } else {
                        // The find succeeded.
                        let audioFile: PFFile = sound!["file"] as! PFFile
                        let loc = sound!["location"] as! PFGeoPoint
                        audioFile.getDataInBackgroundWithBlock({
                            (soundData: NSData?, error: NSError?) -> Void in
                            if (error == nil) {
                                var error: NSError?
                                var closestPlayer = AVAudioPlayer(data: soundData, error: &error)
                                //println("should be playing here")
                                closestPlayer.delegate = self
                                closestPlayer.prepareToPlay()
                                closestPlayer.volume = 1.0
                                closestPlayer.play()
//                                var closestCoords = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
//                                var point1 = MKMapPointForCoordinate(self.currentLocation)
//                                var point2 = MKMapPointForCoordinate(closestCoords)
//                                let distance: CLLocationDistance = MKMetersBetweenMapPoints(point1, point2)
//                                if (distance < 20){
//                                    println("distance: \(distance)")
//                                    if (closestPlayer.playing != true) {
//                                        closestPlayer.prepareToPlay()
//                                        closestPlayer.volume = 3.0
//                                        closestPlayer.play()
//                                        println("playing")
//                                        println(closestPlayer)
//                                        println(sound!["title"])
//                                    }
//                                }
                                
                                
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
        getClosestSound()
        //play closest sound if within min distance to closest coord
        //if
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

