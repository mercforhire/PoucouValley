//
//  ExploreShopsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-29.
//

import Foundation
import RealmSwift

class ExploreShopsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<Merchant> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let merchants = document["data"]??.arrayValue {
            let data: List<Merchant> = List()
            for merchant in merchants {
                data.append(Merchant(document: merchant!.documentValue!))
            }
            self.data = data
        }
    }
}
