//
//  Gift.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-24.
//

import Foundation
import RealmSwift

class Gift: BaseObject {
    var costInCoins: Int = 0
    var createdDate: Date = Date()
    var itemDescription: String = ""
    var itemDescription2: String = ""
    var name: String = ""
    var photos: List<String> = List()
    
    convenience init(document: Document) {
        self.init()
        self.costInCoins = document["costInCoins"]??.asInt() ?? 0
        self.createdDate = document["createdDate"]!!.dateValue!
        self.itemDescription = document["description"]??.stringValue ?? ""
        self.itemDescription2 = document["itemName"]??.stringValue ?? ""
        self.name = document["name"]??.stringValue ?? ""
        if let array = document["photos"]??.arrayValue {
            let data: List<String> = List()
            for photo in array {
                data.append(photo!.stringValue!)
            }
            self.photos = data
        }
    }
}
