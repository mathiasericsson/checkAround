 //
//  CheckAroundTableVewControllerTableViewController.swift
//  checkAround
//
//  Created by Mathias Ericsson on 19/10/16.
//  Copyright © 2016 Mathias Ericsson. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth
import CoreLocation

 //To be able to compare Sweet objects
 extension Array {
    mutating func removeObject<U: Equatable>(Sweet: U) -> Bool {
        for (idx, objectToCompare) in self.enumerated() {
            if let to = objectToCompare as? U {
                if Sweet == to {
                    self.remove(at: idx)
                    return true
                }
            }
        }
        return false
    }
 }
 
 
 
class CheckAroundTableVewControllerTableViewController: UITableViewController, CLLocationManagerDelegate{

    var dbRef:FIRDatabaseReference!
    var sweets = [Sweet]()
    var locationManager:CLLocationManager?
    var currentLocation:CLLocation?
    var geofireRef:FIRDatabaseReference?
    var geoFire:GeoFire?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        //locationManager?.distanceFilter = 5
        locationManager?.startUpdatingLocation()
        
        dbRef = FIRDatabase.database().reference().child("messages")
        geofireRef = FIRDatabase.database().reference().child("positions")
        geoFire = GeoFire(firebaseRef: geofireRef)
        
        //TODO: Do something, like waiting screen when fetching GPS-position
        //startObservingDB()
    }
  
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Use only when creating information, for reading everyone can access
        FIRAuth.auth()?.addStateDidChangeListener({ (auth:FIRAuth, user:FIRUser?) in
            if let user = user{
                print("Welcome: " + user.email!)
                //TODO: Update button to logout button
            }
            else{
                print("You need to sign in first")
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        self.currentLocation = locations[0]
        let circleQuery = geoFire?.query(at: self.currentLocation, withRadius: 0.05) //0.6 = 600 m radius
        
        //If something enters the radius, fetch them from firebase and add them to table view
        circleQuery?.observe(.keyEntered, with: { (key: String?, location: CLLocation?) in
            
            self.dbRef.child(key!).observe(.value, with: { (snapshot) in
               
                if(snapshot.hasChildren()){
                    let sweetObject = Sweet(snapshot:snapshot)
                
                    let results = self.sweets.filter { $0.key == sweetObject.key }
               
                    if(results.isEmpty){
                        self.sweets.append(sweetObject)
                    }
                }
            })
            
            //Seams to now work... maybe not a super big problem though? As it will clear someimes anyway.
            circleQuery?.observe(.keyExited, with: { (key: String?, location: CLLocation?) in
                
                self.removeSweetFromArray(key: key)
            })
        })
        
        self.tableView.reloadData()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
/*THis was used when it was only a chat client, now we use GPS to check for when we get new items
   func startObservingDB(){
            dbRef.observe(.value, with: { (snapshot:FIRDataSnapshot) in
           
            for sweet in snapshot.children{
                
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                
                let results = self.sweets.filter { $0.key == sweetObject.key }
                
                if(results.isEmpty){
                    self.sweets.append(sweetObject)
                    
                }
            }
        
            self.tableView.reloadData()
            
        })
    }
*/
    //Function to add Sweet
    @IBAction func addSweet(_ sender: AnyObject) {

        
        let sweetAlert = UIAlertController(title: "New sweet", message: "Enter your Sweet", preferredStyle: .alert)
        
        
        sweetAlert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your Sweet"
        }
        
        sweetAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
            
             if let sweetContent = sweetAlert.textFields?.first?.text{
                
                let userName = FIRAuth.auth()?.currentUser?.email
                
                let longitude:Double = (self.currentLocation?.coordinate.longitude)!
                let latitude:Double = (self.currentLocation?.coordinate.latitude)!

                //Save Sweet-item
                let sweetRef = self.dbRef.childByAutoId()
            
                let sweet = Sweet(key: sweetRef.key, content: sweetContent, addedByUser: userName!)
                sweetRef.setValue(sweet.toAnyOpbject())
                
                self.geoFire?.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: sweetRef.key)
                
                self.sweets.append(sweet)
                self.tableView.reloadData()
                
                
            }
        }))
        self.present(sweetAlert, animated: true, completion: nil)
    }
    
    @IBAction func loginAndSignUp(_ sender: AnyObject) {
        
        let userAlert = UIAlertController(title: "Login/Sign up", message: "Enter email and password", preferredStyle: .alert)
   
        userAlert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "email"
        }
        
        userAlert.addTextField { (textField : UITextField!) -> Void in
            textField.isSecureTextEntry = true
            textField.placeholder = "password"
        }
        
        userAlert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: { (action:UIAlertAction) in
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!
            
            FIRAuth.auth()?.signIn(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, err) in
                
                if err != nil {
                    print(err?.localizedDescription)
                }
                
            })
     
        }))
        
        userAlert.addAction(UIAlertAction(title: "Sign up", style: .default, handler: { (action:UIAlertAction) in
            
            let emailTextField = userAlert.textFields!.first!
            let passwordTextField = userAlert.textFields!.last!

            
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, err) in
                
                if err != nil {
                    print(err?.localizedDescription)
                }
            })
        }))
       
        self.present(userAlert, animated: true, completion: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sweets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let sweet = sweets[indexPath.row]
        cell.textLabel?.text = sweet.content
        cell.detailTextLabel?.text = sweet.addedByUser
    
        return cell
    }

    //Delete item
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let sweet = sweets[indexPath.row]
            self.removeSweetFromArray(key: sweet.key)
            self.geoFire?.removeKey(sweet.key)
            sweet.itemRef?.removeValue()
            self.tableView.reloadData()
        }
    }
    
    func removeSweetFromArray(key:String!){
        
        var index = 0
        for sweet in self.sweets {
            if sweet.key == key {
                self.sweets.remove(at: index)
                self.tableView.reloadData()
            }
            index += 1
        }
    }
    
}
