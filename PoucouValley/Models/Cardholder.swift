//
//  Cardholder.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Cardholder: Object {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var userId: ObjectId = ObjectId()
    @objc dynamic var card: String?
    @objc dynamic var firstName: String?
    @objc dynamic var lastName: String?
    @objc dynamic var pronoun: String?
    @objc dynamic var gender: String?
    @objc dynamic var birthday: Birthday?
    @objc dynamic var address: Address?
    @objc dynamic var contact: Contact?
    @objc dynamic var avatar: PVPhoto?
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.userId = document["userId"]!!.objectIdValue!
        self.card = document["card"]??.stringValue
        self.firstName = document["firstName"]??.stringValue
        self.lastName = document["lastName"]??.stringValue
        self.pronoun = document["pronoun"]??.stringValue
        self.gender = document["gender"]??.stringValue
        if let document = document["birthday"]??.documentValue {
            self.birthday = Birthday(document: document)
        }
        if let document = document["address"]??.documentValue {
            self.address = Address(document: document)
        }
        if let document = document["contact"]??.documentValue {
            self.contact = Contact(document: document)
        }
        if let document = document["avatar"]??.documentValue {
            self.avatar = PVPhoto(document: document)
        }
    }
}
