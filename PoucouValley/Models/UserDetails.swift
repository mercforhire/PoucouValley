//
//  UserDetails.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class UserDetails: Object {
    @objc dynamic var user: User?
    @objc dynamic var cardholder: Cardholder?
    @objc dynamic var merchant: Merchant?
    
    convenience init(document: Document) {
        self.init()
        self.user = User(document: document["user"]!!.documentValue!)
        if let document = document["cardholder"]??.documentValue {
            self.cardholder = Cardholder(document: document)
        }
        if let document = document["merchant"]??.documentValue {
            self.merchant = Merchant(document: document)
        }
    }
}
