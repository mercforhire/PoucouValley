//
//  FetchWalletResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-24.
//

import Foundation
import RealmSwift

class FetchWalletResponse: BaseObject {
    var success: Bool = false
    var message: String?
    var data: Wallet?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = Wallet(document: data)
        }
    }
}
