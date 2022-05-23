//
//  Address.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Address: BaseEmbeddedObject {
    var unitNumber: String?
    var streetNumber: String?
    var street: String?
    var city: String?
    var province: String?
    var country: String?
    var postalCode: String?
    
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
    
    override func toDocument() -> Document {
        var document: Document = [:]
        if let unitNumber = unitNumber {
            document["unitNumber"] = AnyBSON(unitNumber)
        }
        if let streetNumber = streetNumber {
            document["streetNumber"] = AnyBSON(streetNumber)
        }
        if let street = street {
            document["street"] = AnyBSON(street)
        }
        if let city = city {
            document["city"] = AnyBSON(city)
        }
        if let province = province {
            document["province"] = AnyBSON(province)
        }
        if let country = country {
            document["country"] = AnyBSON(country)
        }
        if let postalCode = postalCode {
            document["postalCode"] = AnyBSON(postalCode)
        }
        return document
    }
}
