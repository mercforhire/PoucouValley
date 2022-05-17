//
//  Contact.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Contact: EmbeddedObject {
    var phoneAreaCode: String?
    var phoneNumber: String?
    var website: String?
    var twitter: String?
    var facebook: String?
    var instagram: String?
    
    init(document: Document) {
        super.init()
        self.phoneAreaCode = document["phoneAreaCode"]??.stringValue
        self.phoneNumber = document["phoneNumber"]??.stringValue
        self.website = document["website"]??.stringValue
        self.twitter = document["twitter"]??.stringValue
        self.facebook = document["facebook"]??.stringValue
        self.instagram = document["instagram"]??.stringValue
    }
}
