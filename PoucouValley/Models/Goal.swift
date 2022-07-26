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
    
    static func == (lhs: Goal, rhs: Goal) -> Bool {
        return lhs.goal == rhs.goal
    }
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.goal = document["goal"]!!.stringValue!
        self.reward = document["reward"]!!.asInt()!
    }
    
    static func supportGoals() -> [String] {
        return ["Add gender to profile", "Add birthday to profile", "Add address to profile", "Add phone number to profile"]
    }
}
