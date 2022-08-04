//
//  AddPlanResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-03.
//

import Foundation
import RealmSwift

class AddPlanResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: Plan?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = Plan(document: data)
        }
    }
}
