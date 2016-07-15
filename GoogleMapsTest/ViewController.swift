//
//  ViewController.swift
//  GoogleMapsTest
//
//  Created by Ray Sabbineni on 7/13/16.
//  Copyright © 2016 Ray Sabbineni. All rights reserved.
//

import UIKit
import GoogleMaps

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, UITextFieldDelegate  {
    
    let locationManager = CLLocationManager()

    let defaultSesion = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
    
    var dataTask : NSURLSessionDataTask?
    var arrayWithMarkerObjects : [AnyObject] = []
    var mapView : GMSMapView!
    var arrayP : [PlaceMarker] = []


    
    var lattitude : Double = 0
    var longitude : Double = 0
    var startSearch : UIButton = UIButton()
    var textField : UITextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    
        self.startSearch = UIButton(frame: CGRectMake(0, self.view.frame.size.height/1.2, 130, 30))
        startSearch.setTitle("Search", forState: .Normal)
        startSearch.setTitleColor(UIColor.blackColor(), forState: .Normal)
        startSearch.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        startSearch.addTarget(self, action:#selector(startSearchPressed), forControlEvents: .TouchUpInside)
    
        self.textField = UITextField(frame: CGRectMake(100, self.view.frame.size.height/1.2, self.view.frame.size.width - 120, 30))
        textField.userInteractionEnabled = true
        textField.placeholder = "Search"
        textField.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
        textField.borderStyle = UITextBorderStyle.RoundedRect
        
   
        
        
    }
    
    
    
    
//    override func viewWillAppear(animated: Bool) {
//     
//        self.startSearch = UIButton(frame: CGRectMake(0, self.view.frame.size.height/2, 130, 100))
//        startSearch.setTitle("Search", forState: .Normal)
//        startSearch.setTitleColor(UIColor.blackColor(), forState: .Normal)
//        startSearch.addTarget(self, action:#selector(startSearchPressed), forControlEvents: .TouchUpInside)
//        startSearch.backgroundColor = UIColor.yellowColor()
//        self.view.addSubview(self.startSearch)
//        view.bringSubviewToFront(self.startSearch)
//        
//
//        
//        
//    }
    
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var locValue:CLLocationCoordinate2D = manager.location!.coordinate
        print("locations = \(locValue.latitude) \(locValue.longitude)")
        lattitude = locValue.latitude
        longitude = locValue.longitude
        
        let camera = GMSCameraPosition.cameraWithLatitude(lattitude,
                                                          longitude: longitude, zoom: 12)
         mapView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)
        mapView.settings.consumesGesturesInView = false
        mapView.myLocationEnabled = true
        print(mapView.myLocationEnabled)
        
        self.view = mapView
        
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2DMake(lattitude, longitude)
        marker.title = "Sydney"
        marker.snippet = "Australia"
        marker.map = mapView
        
        locationManager.stopUpdatingLocation()

        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
     
        self.view.addSubview(self.startSearch)

        self.view.addSubview(self.textField)
//        view.bringSubviewToFront(self.textField)
//        view.bringSubviewToFront(self.startSearch)
        
    }
    
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }


    func startSearchPressed(sender: UIButton)
    {
        print("button pressed")
        searchQuery()
        
        
        
    }
    
    
    func searchQuery() {
      
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/textsearch/json?query=bars&location=40.69644324,-73.94949604&radius=500&key=AIzaSyAWV1BUFv_vcedYroVrY7DWYuIxcHaqrv0")
        
        
        
//        dataTask = defaultSession.dataTaskWithURL(url!) {
//            data, response, error in
//            let json: AnyObject?
        
        
        self.dataTask = defaultSesion.dataTaskWithURL(url!) {
            data, response, error in
//            print(response)
            let json : AnyObject?
            
            do {
                
                json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
//                print(json)
                if let response = json!["results"] as? [[String : AnyObject]]
                {
                    print(response)
                    for resp in response
                    
                    {
                        var markerObject = MarkerModel()
                        
                     if let name = resp["name"] as? String
                     {
//                        print("\(name)")
                        markerObject.name = name
                        
                     }
                     if let address = resp["formatted_address"] as? String
                     {
                        
//                        print("\(address)")
                         markerObject.address = address
                     }
                        
                     if let rating = resp["rating"] as? Double
                     {
                        print("\(rating)")
                        markerObject.rating = rating
                     }
                      
                     if let geometry = resp["geometry"] as? AnyObject!
                     {
                        if let loc = geometry["location"] as AnyObject!
                        {
                            if let lat = loc["lat"] as? Double
                            {
                                var x = lat
                                markerObject.lattitude = x
                                print(markerObject.lattitude)
                            }
                            
                            if let lng = loc["lng"] as? Double
                            {
                                var y = lng
                                markerObject.longitude = y
                                print(markerObject.longitude)
                            }
                            
//                            var x  = loc["lat"]
//                            var y  = loc["lng"]
//                            markerObject.lattitude = x
//                            markerObject.longitude = y
//                            print("lattitude is \(x) and longitude is \(y)")
                        }

                     }
                        self.arrayWithMarkerObjects.append(markerObject)
                        print(self.arrayWithMarkerObjects[0].lattitude)

                    }

                }
                
            }
            catch {
                print("\(error)")
                
            }
        
            dispatch_async(dispatch_get_main_queue())
            {
                self.createMarkers()
            }
            
            
        }
        
   
        dataTask?.resume()
        
        
    } // end function here
    
    
    
    
    func createMarkers() {
        
        // marker desc. 
        print(self.arrayWithMarkerObjects)
        for i  in 0 ..< self.arrayWithMarkerObjects.count {
//            let marker = GMSMarker()
//            marker.position = CLLocationCoordinate2D(latitude: markerObj.lattitude!, longitude: markerObj.longitude!)
//            marker.title = markerObj.name
//            marker.snippet = markerObj.address
//            marker.map = self.mapView
            

            
            print(self,arrayWithMarkerObjects[i].lattitude)
            print(self,arrayWithMarkerObjects[i].longitude)
//            print(self,arrayWithMarkerObjects[i].name)
//            print(self,arrayWithMarkerObjects[i].address)
            var markerS = PlaceMarker(latitude: self.arrayWithMarkerObjects[i].lattitude, longitude: self.arrayWithMarkerObjects[i].longitude, name: self.arrayWithMarkerObjects[i].name, address: self.arrayWithMarkerObjects[i].address!!)

            arrayP.append(markerS)
            arrayP[i].map = self.mapView


        }
        print(arrayP)
        
        for i in 0 ..< arrayP.count {
            arrayP[i].map = self.mapView
        }
        

        print("done")
        
    }
    
    

}



