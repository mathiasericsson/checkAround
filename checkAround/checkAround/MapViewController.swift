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
import FirebaseDatabase



class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    var locationManager:CLLocationManager?
    var dbRef:FIRDatabaseReference!
    var sweets = [Sweet]()
    var currentLocation:CLLocation?
    var geofireRef:FIRDatabaseReference?
    var geoFire:GeoFire?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization() //To only use GPS when app is active, and not in background
        locationManager?.distanceFilter = 5
        locationManager?.startUpdatingLocation()
        
        dbRef = FIRDatabase.database().reference().child("messages")
        geofireRef = FIRDatabase.database().reference().child("positions")
        geoFire = GeoFire(firebaseRef: geofireRef)
        
        self.mapView.showsUserLocation = true
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
 
        let location = locations.last
       
        
        
        let circleQuery = geoFire?.query(at: self.currentLocation, withRadius: 0.05)
        //0.6 = 600 m radius
        
        print("Something")
        
        //If something enters the radius, fetch them from firebase and add them to table view
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            
            print("circle")
            self.dbRef.child(key!).observe(.value, with: { (snapshot) in
                
                print("observe")
                if(snapshot.hasChildren()){
                    
                    print("has children")
                    let sweetObject = Sweet(snapshot:snapshot)
                    
                    let results = self.sweets.filter { $0.key == sweetObject.key }
                    
                    if(results.isEmpty){
                        print("Object:")
                        print(sweetObject)
                        self.sweets.append(sweetObject)
                    }
                }
            })
            
            //Seams to now work... maybe not a super big problem though? As it will clear someimes anyway.
            circleQuery?.observe(.keyExited, with: { (key: String?, location: CLLocation?) in
                
                //self.removeSweetFromArray(key: key) TODO: Do I need this?
            })
            print(self.sweets)
        })
        
        //Zoom in map
        let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center:center, span:span)
        self.mapView.setRegion(region, animated: true)
        self.locationManager?.stopUpdatingLocation()
        
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error:" + error.localizedDescription)
    }
}
