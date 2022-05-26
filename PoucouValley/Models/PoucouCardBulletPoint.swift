//
//  PoucouCardBulletPoint.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-24.
//

import Foundation
import RealmSwift

class PoucouCardBulletPoint: BaseObject {
    var identifier: ObjectId = ObjectId()
    var iconName: String?
    var order: Int = 0
    var title: String = ""
    var subtitle: String?

    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.iconName = document["iconName"]??.stringValue
        self.order = document["order"]!!.asInt()!
        self.title = document["title"]!!.stringValue!
        self.subtitle = document["subtitle"]??.stringValue
    }
}
