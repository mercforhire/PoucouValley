//
//  UpdateCardholderInfoParams.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import Foundation
import RealmSwift

struct UpdateCardholderInfoParams {
    var apiKey: String
    var firstName: String?
    var lastName: String?
    var pronoun: String?
    var gender: String?
    var birthday: Birthday?
    var contact: Contact?
    var address: Address?
    var avatar: PVPhoto?
    
    func params() -> [AnyBSON] {
        var array: [AnyBSON] = []
        array.append(AnyBSON(apiKey))
        
        var params: Document = [:]
        
        if let firstName = firstName {
            params["firstName"] = AnyBSON(firstName)
        }
        
        if let lastName = lastName {
            params["lastName"] = AnyBSON(lastName)
        }
        
        if let pronoun = pronoun {
            params["pronoun"] = AnyBSON(pronoun)
        }
        
        if let gender = gender {
            params["gender"] = AnyBSON(gender)
        }
        
        if let birthday = birthday {
            params["birthday"] = AnyBSON(birthday.toDocument())
        }
        
        if let contact = contact {
            params["contact"] = AnyBSON(contact.toDocument())
        }
        
        if let address = address {
            params["address"] = AnyBSON(address.toDocument())
        }
        
        if let avatar = avatar {
            params["avatar"] = AnyBSON(avatar.toDocument())
        }
        
        array.append(AnyBSON(params))
        return array
    }
}
