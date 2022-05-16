//
//  Address.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Address: EmbeddedObject {
    var unitNumber: String?
    var streetNumber: String?
    var street: String?
    var city: String?
    var province: String?
    var country: String?
    var postalCode: String?
    
    init(document: Document) {
        super.init()
        self.unitNumber = document["unitNumber"]??.stringValue
        self.streetNumber = document["streetNumber"]??.stringValue
        self.street = document["street"]??.stringValue
        self.city = document["city"]??.stringValue
        self.province = document["province"]??.stringValue
        self.country = document["country"]??.stringValue
        self.postalCode = document["postalCode"]??.stringValue
    }
}
