//
//  GetBusinessTypesResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-22.
//

import Foundation
import RealmSwift

class GetBusinessTypesResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<BusinessType> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let steps = document["data"]??.arrayValue {
            let data: List<BusinessType> = List()
            for step in steps {
                data.append(BusinessType(document: step!.documentValue!))
            }
            self.data = data
        }
    }
}
