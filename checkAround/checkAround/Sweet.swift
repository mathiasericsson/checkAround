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
    let itemRef: FIRDatabaseReference?
    
    init(content:String, addedByUser:String, key:String = ""){
        self.key = key
        self.content =  content
        self.addedByUser =  addedByUser
        self.itemRef = nil

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

        let snapshotValue2 = snapshot.value as? NSDictionary
        
        if let sweetUser = snapshotValue2!["addedByUser"] as? String{
            addedByUser = sweetUser
        }else{
            addedByUser = ""
        }

    }
    
    func toAnyOpbject() -> [AnyHashable:Any]{
        
        return ["content":content, "addedByUser":addedByUser] as [AnyHashable:Any]
        
    }
    
}

