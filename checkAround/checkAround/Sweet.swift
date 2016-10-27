//
//  Sweet.swift
//  checkAround
//
//  Created by Mathias Ericsson on 19/10/16.
//  Copyright © 2016 Mathias Ericsson. All rights reserved.
//

import Foundation
import FirebaseDatabase


/* Datatype */
struct Sweet{
    
    let key:String!
    let content:String!
    let addedByUser:String!
    let position:Array<Double>!
    let itemRef: FIRDatabaseReference?
    
    init(content:String, addedByUser:String, key:String = "", position:Array<Double>){
        self.key = key
        self.content =  content
        self.addedByUser =  addedByUser
        self.itemRef = nil
        self.position = position

    }
    init(snapshot:FIRDataSnapshot){
        key = snapshot.key
        itemRef = snapshot.ref
        
        let snapshotValue = snapshot.value as? NSDictionary
        
        if let sweetContent = snapshotValue!["content"] as? String{
            content = sweetContent
        }else{
            content = ""
        }

        let snapshotUser = snapshot.value as? NSDictionary
        
        if let sweetUser = snapshotUser!["addedByUser"] as? String{
            addedByUser = sweetUser
        }else{
            addedByUser = ""
        }
        
        let snapshotPosition = snapshot.value as? NSDictionary
        
        
        if let sweetPosition = snapshotPosition!["position"] as? Array<Double>{
            position = sweetPosition
        }else{
            position = [111,111]
        }
        
    }

    func toAnyOpbject() -> [AnyHashable:Any]{
        
        return ["content":content, "addedByUser":addedByUser, "position":position] as [AnyHashable:Any]
        
    }
    
}

