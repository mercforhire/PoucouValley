//
//  GetVisitorsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-04.
//

import Foundation
import RealmSwift

class GetVisitorsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<VisitorRecord> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let array = document["data"]??.arrayValue {
            let data: List<VisitorRecord> = List()
            for document in array {
                data.append(VisitorRecord(document: document!.documentValue!))
            }
            self.data = data
        }
    }
}
