//
//  UpdateMerchantInfoParams.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-23.
//

import Foundation
import RealmSwift

struct UpdateMerchantInfoParams {
    var name: String?
    var field: BusinessCategories?
    var logo: PVPhoto?
    var photos: [PVPhoto]?
    var contact: Contact?
    var address: Address?
    var cards: [String]?
    var description: String?
    var hashtags: [String]?
    
    func toDocument() -> Document {
        var params: Document = [:]
        
        if let name = name {
            params["name"] = AnyBSON(name)
        }
        
        if let field = field {
            params["field"] = AnyBSON(field.rawValue)
        }
        
        if let logo = logo {
            params["logo"] = AnyBSON(logo.toDocument())
        }
        
        if let description = description {
            params["description"] = AnyBSON(description)
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
        
        if let hashtags = hashtags {
            var array: [AnyBSON] = []
            _ = hashtags.map { array.append(AnyBSON($0)) }
            params["hashtags"] = AnyBSON(array)
        }
        
        return params
    }
}
