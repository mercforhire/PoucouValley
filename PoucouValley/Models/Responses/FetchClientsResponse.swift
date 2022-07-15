//
//  FetchClientsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-14.
//

import Foundation
import RealmSwift

class FetchClientsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Client> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let steps = document["data"]??.arrayValue {
            let data: List<Client> = List()
            for step in steps {
                data.append(Client(document: step!.documentValue!))
            }
            self.data = data
        }
    }
}
