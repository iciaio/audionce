//
//  soundAnnotation.swift
//  soundapp
//
//  Created by Alicia Iott on 6/3/15.
//  Copyright (c) 2015 Alicia Iott. All rights reserved.
//

import Foundation
import MapKit

class Sound: NSObject, MKAnnotation {
    let title: String
    let locationName: String
    let discipline: String
    let coordinate: CLLocationCoordinate2D
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
}