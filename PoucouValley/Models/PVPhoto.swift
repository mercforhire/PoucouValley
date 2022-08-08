//
//  PVPhoto.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class PVPhoto: BaseEmbeddedObject {
    var thumbnailUrl: String = ""
    var fullUrl: String = ""
    
    static func == (lhs: PVPhoto, rhs: PVPhoto) -> Bool {
        return lhs.thumbnailUrl == rhs.thumbnailUrl && lhs.fullUrl == rhs.fullUrl
    }
    
    convenience init(thumbnailUrl: String, fullUrl: String) {
        self.init()
        self.thumbnailUrl = thumbnailUrl
        self.fullUrl = fullUrl
    }
    
    convenience init(document: Document) {
        self.init()
        self.thumbnailUrl = document["thumbnailUrl"]??.stringValue ?? ""
        self.fullUrl = document["fullUrl"]??.stringValue ?? ""
    }
    
    override func toDocument() -> Document {
        var document: Document = [:]
        document["thumbnailUrl"] = AnyBSON(thumbnailUrl)
        document["fullUrl"] = AnyBSON(fullUrl)
        return document
    }
}
