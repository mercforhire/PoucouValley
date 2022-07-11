//
//  Client.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Client: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var ownerId: ObjectId = ObjectId()
    var cardholderUserId: ObjectId?
    var firstName: String?
    var lastName: String?
    var pronoun: String?
    var gender: String?
    var birthday: Birthday?
    var address: Address?
    var contact: Contact?
    var avatar: PVPhoto?
    var company: String?
    var jobTitle: String?
    var hashtags: List<String> = List()
    var notes: String?
    var email: String?
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.ownerId = document["ownerId"]!!.objectIdValue!
        self.cardholderUserId = document["cardholderUserId"]??.objectIdValue
        self.firstName = document["firstName"]??.stringValue
        self.lastName = document["lastName"]??.stringValue
        self.pronoun = document["pronoun"]??.stringValue
        self.gender = document["gender"]??.stringValue
        self.company = document["company"]??.stringValue
        self.jobTitle = document["jobTitle"]??.stringValue
        self.notes = document["notes"]??.stringValue
        self.email = document["email"]??.stringValue
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
        if let array = document["hashtags"]??.arrayValue {
            let data: List<String> = List()
            for tag in array {
                data.append(tag!.stringValue!)
            }
            self.hashtags = data
        }
    }
}
