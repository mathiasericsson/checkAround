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
 
class CheckAroundTableVewControllerTableViewController: UITableViewController {

    var dbRef:FIRDatabaseReference!
    var sweets = [Sweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dbRef = FIRDatabase.database().reference().child("sweet-items") //Structure data in JSON hirarchy
        startObservingDB()
    }

   func startObservingDB(){
            dbRef.observe(.value, with: { (snapshot:FIRDataSnapshot) in
           
            var newSweets = [Sweet]()
            
            for sweet in snapshot.children{
                let sweetObject = Sweet(snapshot: sweet as! FIRDataSnapshot)
                newSweets.append(sweetObject)
            }
            self.sweets = newSweets
            self.tableView.reloadData()
            
        })
    }

    @IBAction func addSweet(_ sender: AnyObject) {

        
        let sweetAlert = UIAlertController(title: "New sweet", message: "Enter your Sweet", preferredStyle: .alert)
        
        
        sweetAlert.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Your Sweet"
        }
        sweetAlert.addAction(UIAlertAction(title: "Send", style: .default, handler: { (action:UIAlertAction) in
            if let sweetContent = sweetAlert.textFields?.first?.text {
                let sweet = Sweet(content: sweetContent, addedByUser: "Nils Holgersson")
                let sweetRef = self.dbRef.child(sweetContent.lowercased())
                sweetRef.setValue(sweet.toAnyOpbject())
            }
        }))
        
        self.present(sweetAlert, animated: true, completion: nil)
    }
    
    @IBAction func refresh(_ sender: AnyObject) {
        self.tableView.reloadData()
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

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let sweet = sweets[indexPath.row]
            sweet.itemRef?.removeValue()
            self.tableView.reloadData()
        }
    }
    

   
}
