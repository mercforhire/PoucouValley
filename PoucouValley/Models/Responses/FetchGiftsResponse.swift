//
//  FetchGiftsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-24.
//

import Foundation
import RealmSwift

class FetchGiftsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Gift> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let gifts = document["data"]??.arrayValue {
            let data: List<Gift> = List()
            for gift in gifts {
                data.append(Gift(document: gift!.documentValue!))
            }
            self.data = data
        }
    }
}
