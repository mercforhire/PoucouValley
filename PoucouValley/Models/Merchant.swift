//
//  Merchant.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Merchant: Object {
    var identifier: ObjectId
    var createdDate: Date
    var userId: ObjectId
    var name: String?
    var field: String?
    var logo: PVPhoto?
    var address: Address?
    var contact: Contact?
    var photos: List<PVPhoto> = List()
    var cards: List<String> = List()
    
    init(document: Document) {
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.userId = document["userId"]!!.objectIdValue!
        super.init()
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
            let data: List<String> = List()
            for card in array {
                data.append(card!.stringValue!)
            }
            self.cards = data
        }
    }
}
