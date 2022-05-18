//
//  User.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class User: Object {
    @objc dynamic var identifier: ObjectId = ObjectId()
    @objc dynamic var email: String = ""
    var userType: UserTypeMode = .cardholder
    @objc dynamic var createdDate: Date = Date()
    @objc dynamic var apiKey: String = ""
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.email = document["email"]!!.stringValue!
        self.userType = UserTypeMode(rawValue: document["userType"]!!.stringValue!) ?? .cardholder
        self.createdDate = document["createdDate"]!!.dateValue!
        self.apiKey = document["apiKey"]!!.stringValue!
    }
}
