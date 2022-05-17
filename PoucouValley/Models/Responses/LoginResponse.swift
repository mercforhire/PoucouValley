//
//  LoginResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class LoginResponse: Object {
    var success: Bool
    var message: String?
    var data: UserDetails?
    
    init(document: Document) {
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = UserDetails(document: data)
        }
        super.init()
    }
}
