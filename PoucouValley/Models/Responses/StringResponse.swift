//
//  StringResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-20.
//

import Foundation
import RealmSwift

class StringResponse: BaseObject {
    var success: Bool = false
    var message: String?
    var data: String?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        self.data = document["data"]??.stringValue
    }
}
