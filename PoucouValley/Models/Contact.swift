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
    
    init(document: Document) {
        super.init()
        self.phoneAreaCode = document["phoneAreaCode"]??.stringValue
        self.phoneNumber = document["phoneNumber"]??.stringValue
    }
}
