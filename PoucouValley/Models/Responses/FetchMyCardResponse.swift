//
//  FetchMyCardResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-25.
//

import UIKit
import RealmSwift

class FetchMyCardResponse: BaseObject {
    var success: Bool = false
    var message: String?
    var data: Card?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = Card(document: data)
        }
    }
}
