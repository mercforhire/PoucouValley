//
//  SearchPlansResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-30.
//

import Foundation
import RealmSwift

class SearchPlansResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Plan> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let dataArray = document["data"]??.arrayValue {
            let plans: List<Plan> = List()
            for data in dataArray {
                plans.append(Plan(document: data!.documentValue!))
            }
            self.data = plans
        }
    }
}
