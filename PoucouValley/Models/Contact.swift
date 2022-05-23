//
//  Contact.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Contact: BaseEmbeddedObject {
    var phoneAreaCode: String?
    var phoneNumber: String?
    var website: String?
    var twitter: String?
    var facebook: String?
    var instagram: String?
    
    convenience init(document: Document) {
        self.init()
        self.phoneAreaCode = document["phoneAreaCode"]??.stringValue
        self.phoneNumber = document["phoneNumber"]??.stringValue
        self.website = document["website"]??.stringValue
        self.twitter = document["twitter"]??.stringValue
        self.facebook = document["facebook"]??.stringValue
        self.instagram = document["instagram"]??.stringValue
    }
    
    override func toDocument() -> Document {
        var document: Document = [:]
        if let phoneAreaCode = phoneAreaCode {
            document["phoneAreaCode"] = AnyBSON(phoneAreaCode)
        }
        if let phoneNumber = phoneNumber {
            document["phoneNumber"] = AnyBSON(phoneNumber)
        }
        if let website = website {
            document["website"] = AnyBSON(website)
        }
        if let twitter = twitter {
            document["twitter"] = AnyBSON(twitter)
        }
        if let facebook = facebook {
            document["facebook"] = AnyBSON(facebook)
        }
        if let instagram = instagram {
            document["instagram"] = AnyBSON(instagram)
        }
        return document
    }
}
