//
//  FetchClientResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-21.
//

import Foundation
import RealmSwift

class FetchClientResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: Client?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = Client(document: data)
        }
    }
}
