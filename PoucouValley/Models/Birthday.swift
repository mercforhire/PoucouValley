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
    
    var dateString: String {
        let monthName = DateFormatter().monthSymbols[month - 1]
        return "\(year) \(monthName), \(day)"
    }
    
    var date: Date? {
        return Date.makeDate(year: year, month: month, day: day)
    }
    
    convenience init(day: Int, month: Int, year: Int) {
        self.init()
        self.day = day
        self.month = month
        self.year = year
    }
    
    convenience init(document: Document) {
        self.init()
        self.day = document["day"]??.asInt() ?? 0
        self.month = document["month"]??.asInt() ?? 0
        self.year = document["year"]??.asInt() ?? 0
    }
    
    override func toDocument() -> Document {
        var document: Document = [:]
        document["day"] = AnyBSON(day)
        document["month"] = AnyBSON(month)
        document["year"] = AnyBSON(year)
        return document
    }
}
