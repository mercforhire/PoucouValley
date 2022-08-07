//
//  Gift.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-24.
//

import Foundation
import RealmSwift

class Gift: BaseObject {
    var identifier: ObjectId = ObjectId()
    var costInCoins: Int = 0
    var createdDate: Date = Date()
    var itemDescription: String = ""
    var itemDescription2: String = ""
    var name: String = ""
    var photos: List<PVPhoto> = List()
    
    convenience init(document: Document) {
        self.init()
        self.identifier = document["_id"]!!.objectIdValue!
        self.costInCoins = document["costInCoins"]??.asInt() ?? 0
        self.createdDate = document["createdDate"]!!.dateValue!
        self.name = document["name"]??.stringValue ?? ""
        self.itemDescription = document["description"]??.stringValue ?? ""
        self.itemDescription2 = document["description2"]??.stringValue ?? ""
        
        if let array = document["photos"]??.arrayValue {
            let data: List<PVPhoto> = List()
            for photo in array {
                guard let documentValue = photo!.documentValue else { continue }
                
                data.append(PVPhoto(document: documentValue))
            }
            self.photos = data
        }
    }
}
