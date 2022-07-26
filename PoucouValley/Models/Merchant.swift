//
//  Merchant.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Merchant: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var userId: ObjectId = ObjectId()
    var name: String?
    var field: String?
    var logo: PVPhoto?
    var address: Address?
    var contact: Contact?
    var photos: List<PVPhoto> = List()
    var cards: List<Card> = List()
    
    convenience init(document: Document) {
        self.init()
        
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.userId = document["userId"]!!.objectIdValue!
        self.name = document["name"]??.stringValue
        self.field = document["field"]??.stringValue
        if let document = document["logo"]??.documentValue {
            self.logo = PVPhoto(document: document)
        }
        if let document = document["address"]??.documentValue {
            self.address = Address(document: document)
        }
        if let document = document["contact"]??.documentValue {
            self.contact = Contact(document: document)
        }
        if let array = document["photos"]??.arrayValue {
            let data: List<PVPhoto> = List()
            for photo in array {
                data.append(PVPhoto(document: photo!.documentValue!))
            }
            self.photos = data
        }
        if let array = document["cards"]??.arrayValue {
            let data: List<Card> = List()
            for card in array {
                data.append(Card(document: card!.documentValue!))
            }
            self.cards = data
        }
    }
}
