//
//  UpdateMerchantResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import Foundation
import RealmSwift

class UpdateMerchantResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: Merchant?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]!!.documentValue {
            self.data = Merchant(document: data)
        }
    }
}
