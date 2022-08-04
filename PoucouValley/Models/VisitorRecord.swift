//
//  VisitorRecord.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-04.
//

import Foundation
import RealmSwift

class VisitorRecord: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var userId: ObjectId = ObjectId()
    var merchantUserId: ObjectId = ObjectId()
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.userId = document["userId"]!!.objectIdValue!
        self.merchantUserId = document["merchantUserId"]!!.objectIdValue!
    }
}
