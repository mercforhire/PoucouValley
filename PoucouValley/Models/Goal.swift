//
//  Goal.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-29.
//

import Foundation
import RealmSwift

class Goal: BaseObject {
    var identifier: ObjectId = ObjectId()
    var goal: String = ""
    var reward: Int = 0
    
    convenience init(document: Document) {
        self.init()
        self.goal = document["goal"]!!.stringValue!
        self.reward = document["reward"]!!.asInt()!
    }
}
