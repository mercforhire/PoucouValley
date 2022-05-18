//
//  Address.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Address: EmbeddedObject {
    @objc dynamic var unitNumber: String?
    @objc dynamic var streetNumber: String?
    @objc dynamic var street: String?
    @objc dynamic var city: String?
    @objc dynamic var province: String?
    @objc dynamic var country: String?
    @objc dynamic var postalCode: String?
    
    convenience init(document: Document) {
        self.init()
        self.unitNumber = document["unitNumber"]??.stringValue
        self.streetNumber = document["streetNumber"]??.stringValue
        self.street = document["street"]??.stringValue
        self.city = document["city"]??.stringValue
        self.province = document["province"]??.stringValue
        self.country = document["country"]??.stringValue
        self.postalCode = document["postalCode"]??.stringValue
    }
}
