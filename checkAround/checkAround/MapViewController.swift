//
//  MapViewController.swift
//  checkAround
//
//  Created by Mathias Ericsson on 01/11/16.
//  Copyright © 2016 Mathias Ericsson. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.locationManager = UserLocation.sharedInstance.locationManager
        self.mapView.showsUserLocation = true
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization() //To only use GPS when app is active, and not in background
        //locationManager?.distanceFilter = 0
        locationManager?.startUpdatingLocation()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        print("Updated location")
        let location = locations.last
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        
        let region = MKCoordinateRegion(center:center, span:span)
    
        print("Hej")
    
        self.mapView.setRegion(region, animated: true)
    
        print("zoom")
        self.locationManager?.stopUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:" + error.localizedDescription)
    }
}
