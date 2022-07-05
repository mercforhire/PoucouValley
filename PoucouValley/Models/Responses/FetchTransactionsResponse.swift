//
//  FetchTransactionsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-30.
//

import Foundation
import RealmSwift

class FetchTransactionsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Transaction> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let steps = document["data"]??.arrayValue {
            let data: List<Transaction> = List()
            for step in steps {
                data.append(Transaction(document: step!.documentValue!))
            }
            self.data = data
        }
    }
}
