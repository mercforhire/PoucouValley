//
//  Card.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-25.
//

import UIKit
import RealmSwift

class Card: BaseObject {
    var identifier: ObjectId = ObjectId()
    var number: String = ""
    var pin: String = ""
    var associatedMerchant: Merchant?
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.number = document["number"]!!.stringValue!
        self.pin = document["pin"]!!.stringValue!
        if let document = document["associatedMerchant"]??.documentValue {
            self.associatedMerchant = Merchant(document: document)
        }
    }
}
