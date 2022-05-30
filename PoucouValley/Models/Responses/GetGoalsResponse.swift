//
//  GetGoalsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-29.
//

import Foundation
import RealmSwift

class GetGoalsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Goal> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let goals = document["data"]??.arrayValue {
            let data: List<Goal> = List()
            for goal in goals {
                data.append(Goal(document: goal!.documentValue!))
            }
            self.data = data
        }
    }
}
