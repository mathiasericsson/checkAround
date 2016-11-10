//
//  UserLocation.swift
//  checkAround
//
//  Created by Mathias Ericsson on 09/11/16.
//  Copyright © 2016 Mathias Ericsson. All rights reserved.
//

import MapKit

class UserLocation: NSObject, CLLocationManagerDelegate {
    
    
    static let sharedInstance = UserLocation() //Maybe creates a singletion... or?
    @IBOutlet weak var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocation2d:CLLocationCoordinate2D?
    
    
    override init() {
        
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization() //To only use GPS when app is active, and not ibackground
        //locationManager.distanceFilter = 5
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 500, longitudeDelta: 500)
        
        let region = MKCoordinateRegion(center:center, span:span)
        
        self.mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:" + error.localizedDescription)
    }
    
}
