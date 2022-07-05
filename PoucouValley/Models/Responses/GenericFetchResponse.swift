//
//  GenericFetchResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-06-01.
//

import Foundation
import RealmSwift

class GenericFetchResponse<T: BaseObject>: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: T?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]!!.documentValue {
            self.data = T(document: data)
        }
    }
}
