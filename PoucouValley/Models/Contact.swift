//
//  Contact.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Contact: EmbeddedObject {
    @objc dynamic var phoneAreaCode: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var website: String?
    @objc dynamic var twitter: String?
    @objc dynamic var facebook: String?
    @objc dynamic var instagram: String?
    
    convenience init(document: Document) {
        self.init()
        self.phoneAreaCode = document["phoneAreaCode"]??.stringValue
        self.phoneNumber = document["phoneNumber"]??.stringValue
        self.website = document["website"]??.stringValue
        self.twitter = document["twitter"]??.stringValue
        self.facebook = document["facebook"]??.stringValue
        self.instagram = document["instagram"]??.stringValue
    }
}
