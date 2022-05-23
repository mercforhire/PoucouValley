//
//  UpdateMerchantInfoParams.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import Foundation
import RealmSwift

struct UpdateMerchantInfoParams {
    var apiKey: String
    var name: String?
    var field: String?
    var logo: PVPhoto?
    var photos: [PVPhoto]?
    var contact: Contact?
    var address: Address?
    var cards: [String]?
    
    func params() -> [AnyBSON] {
        var array: [AnyBSON] = []
        array.append(AnyBSON(apiKey))
        
        var params: Document = [:]
        
        if let name = name {
            params["name"] = AnyBSON(name)
        }
        
        if let field = field {
            params["field"] = AnyBSON(field)
        }
        
        if let logo = logo {
            params["logo"] = AnyBSON(logo.toDocument())
        }
        
        if let photos = photos {
            var array: [AnyBSON] = []
            _ = photos.map { array.append(AnyBSON($0.toDocument())) }
            params["photos"] = AnyBSON(array)
        }
        
        if let contact = contact {
            params["contact"] = AnyBSON(contact.toDocument())
        }
        
        if let address = address {
            params["address"] = AnyBSON(address.toDocument())
        }
        
        if let cards = cards {
            var array: [AnyBSON] = []
            _ = cards.map { array.append(AnyBSON($0)) }
            params["photos"] = AnyBSON(array)
        }
        
        array.append(AnyBSON(params))
        return array
    }
}
