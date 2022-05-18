//
//  LoginResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class LoginResponse: Object {
    @objc dynamic var success: Bool = false
    @objc dynamic var message: String?
    @objc dynamic var data: UserDetails?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = UserDetails(document: data)
        }
    }
}
