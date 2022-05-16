//
//  User.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class User: Object {
    var identifier: ObjectId
    var email: String
    var userType: UserTypeMode
    var createdDate: Date
    var apiKey: String
    
    init(document: Document) {
        self.identifier = document["_id"]!!.objectIdValue!
        self.email = document["email"]!!.stringValue!
        self.userType = UserTypeMode(rawValue: document["userType"]!!.stringValue!) ?? .cardholder
        self.createdDate = document["createdDate"]!!.dateValue!
        self.apiKey = document["apiKey"]!!.stringValue!
        super.init()
    }
}
