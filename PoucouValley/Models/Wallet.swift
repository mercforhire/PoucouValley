//
//  Wallet.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-06-01.
//

import Foundation
import RealmSwift

class Wallet: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var userId: ObjectId = ObjectId()
    var coins: Int = 0
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.userId = document["userId"]!!.objectIdValue!
        self.coins = document["coins"]!!.asInt()!
    }
}
