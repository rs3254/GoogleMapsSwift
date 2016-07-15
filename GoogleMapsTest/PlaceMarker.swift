//
//  PlaceMarker.swift
//  GoogleMapsTest
//
//  Created by Ray Sabbineni on 7/14/16.
//  Copyright © 2016 Ray Sabbineni. All rights reserved.
//

import UIKit
import GoogleMaps

class PlaceMarker: GMSMarker {
    
    
    init(latitude: Double, longitude: Double, name: String, address : String ) {
        super.init()

        
        self.title = name
        self.snippet = address
        self.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        
  
    }


}
