//
//  User.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class User: BaseObject {
    var identifier: ObjectId = ObjectId()
    var email: String = ""
    var userType: UserType = .cardholder
    var apiKey: String = ""
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.email = document["email"]!!.stringValue!
        self.userType = UserType(rawValue: document["userType"]!!.stringValue!) ?? .cardholder
        self.apiKey = document["apiKey"]!!.stringValue!
    }
}
