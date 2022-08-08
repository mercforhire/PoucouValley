//
//  Plan.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-29.
//

import Foundation
import RealmSwift

class Plan: BaseObject {
    var identifier: ObjectId = ObjectId()
    var createdDate: Date = Date()
    var planDescription: String?
    var merchant: ObjectId = ObjectId()
    var photos: List<PVPhoto> = List()
    var title: String?
    var price: Double?
    var discountedPrice: Double?
    var hashtags: List<String> = List()
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.createdDate = document["createdDate"]!!.dateValue!
        self.planDescription = document["description"]??.stringValue
        self.merchant = document["merchant"]!!.objectIdValue!
        if let array = document["photos"]??.arrayValue {
            let data: List<PVPhoto> = List()
            for photo in array {
                data.append(PVPhoto(document: photo!.documentValue!))
            }
            self.photos = data
        }
        self.title = document["title"]??.stringValue ?? ""
        self.price = document["price"]??.asDouble()
        self.discountedPrice = document["discountedPrice"]??.asDouble()
        if let array = document["hashtags"]??.arrayValue {
            let data: List<String> = List()
            for tag in array {
                data.append(tag!.stringValue!)
            }
            self.hashtags = data
        }
    }
}
