//
//  StringArrayResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-09.
//

import Foundation
import RealmSwift

class StringArrayResponse: BaseObject {
    var success: Bool = false
    var message: String?
    var data: List<String> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]??.stringValue
        if let strings = document["data"]??.arrayValue {
            let data: List<String> = List()
            for string in strings {
                guard let string = string?.stringValue else { continue }
                
                data.append(string)
            }
            self.data = data
        }
    }
}
