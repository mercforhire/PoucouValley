//
//  PVPhoto.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class PVPhoto: BaseEmbeddedObject {
    var thumbnameUrl: String = ""
    var fullUrl: String = ""
    
    convenience init(document: Document) {
        self.init()
        self.thumbnameUrl = document["thumbnameUrl"]!!.stringValue!
        self.fullUrl = document["fullUrl"]!!.stringValue!
    }
    
    override func toDocument() -> Document {
        var document: Document = [:]
        document["thumbnameUrl"] = AnyBSON(thumbnameUrl)
        document["fullUrl"] = AnyBSON(fullUrl)
        return document
    }
}
