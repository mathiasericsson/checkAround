//
//  User.swift
//  checkAround
//
//  Created by Mathias Ericsson on 19/10/16.
//  Copyright © 2016 Mathias Ericsson. All rights reserved.
//

import Foundation
import FirebaseAuth

struct User{
    let uid:String
    let email:String
    
    init(userData:FIRUser){
        uid = userData.uid
        
        if let mail = userData.providerData.first?.email{
            email = mail;
        }
        else{
            email = "";
        }
    }
    
    init (uid:String, email:String){
        self.uid = uid
        self.email = email
    }
    
}
