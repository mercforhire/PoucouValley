//
//  UserDetails.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class UserDetails: Object {
    var user: User
    var cardholder: Cardholder?
    var merchant: Merchant?
    
    init(document: Document) {
        self.user = User(document: document["user"]!!.documentValue!)
        super.init()
        if let document = document["cardholder"]??.documentValue {
            self.cardholder = Cardholder(document: document)
        }
        if let document = document["merchant"]??.documentValue {
            self.merchant = Merchant(document: document)
        }
    }
}
