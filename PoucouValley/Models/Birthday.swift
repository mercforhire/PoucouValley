//
//  Birthday.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Birthday: EmbeddedObject {
    var day: Int?
    var month: Int?
    var year: Int?
    
    init(document: Document) {
        super.init()
        self.day = document["day"]??.asInt()
        self.month = document["month"]??.asInt()
        self.year = document["year"]??.asInt()
    }
}
