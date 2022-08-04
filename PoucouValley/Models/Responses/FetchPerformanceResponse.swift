//
//  FetchPerformanceResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-04.
//

import Foundation
import RealmSwift

class FetchPerformanceResponse: BaseObject {
    var success: Bool = false
    var message: String?
    var data: PerformanceData?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = PerformanceData(document: data)
        }
    }
}
