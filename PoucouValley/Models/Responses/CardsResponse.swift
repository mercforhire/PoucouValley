//
//  CardsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-11.
//

import Foundation
import RealmSwift

class CardsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Card> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let dataArray = document["data"]??.arrayValue {
            let data: List<Card> = List()
            for document in dataArray {
                data.append(Card(document: document!.documentValue!))
            }
            self.data = data
        }
    }
}
