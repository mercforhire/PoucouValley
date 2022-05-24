//
//  Cardholder.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Cardholder: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var userId: ObjectId = ObjectId()
    var card: String?
    var firstName: String?
    var lastName: String?
    var pronoun: String?
    var gender: String?
    var birthday: Birthday?
    var address: Address?
    var contact: Contact?
    var avatar: PVPhoto?
    var interests: List<String> = List()
    
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
        if let array = document["interests"]??.arrayValue {
            let data: List<String> = List()
            for interest in array {
                data.append(interest!.stringValue!)
            }
            self.interests = data
        }
    }
}
