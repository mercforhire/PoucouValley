//
//  BusinessType.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import Foundation
import RealmSwift

class BusinessType: BaseObject {
    var identifier: ObjectId = ObjectId()
    var type: String = ""
    var order: Int = 0
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.type = document["type"]!!.stringValue!
        self.order = document["order"]!!.asInt()!
    }
}
