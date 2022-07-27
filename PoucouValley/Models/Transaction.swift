//
//  Transaction.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import Foundation
import RealmSwift

class Transaction: BaseObject {
    var cost: Int = 0
    var createdDate: Date = Date()
    var itemId: ObjectId?
    var itemName: String = ""
    var itemType: String = ""
    var merchant: Merchant?
    
    convenience init(document: Document) {
        self.init()
        self.cost = document["cost"]!!.asInt()!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.itemId = document["itemId"]??.objectIdValue
        self.itemName = document["itemName"]??.stringValue ?? ""
        self.itemType = document["itemType"]??.stringValue ?? ""
        if let data = document["merchant"]??.documentValue {
            self.merchant = Merchant(document: data)
        }
    }
}
