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
    
    convenience init(document: Document) {
        self.init()
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
    }
}
