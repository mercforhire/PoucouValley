//
//  Birthday.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class Birthday: BaseEmbeddedObject {
    var day: Int = 0
    var month: Int = 0
    var year: Int = 0
    
    convenience init(document: Document) {
        self.init()
        self.day = document["day"]??.asInt() ?? 0
        self.month = document["month"]??.asInt() ?? 0
        self.year = document["year"]??.asInt() ?? 0
    }
}
