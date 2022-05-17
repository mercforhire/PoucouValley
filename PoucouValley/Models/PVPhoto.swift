//
//  PVPhoto.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class PVPhoto: EmbeddedObject {
    var thumbnameUrl: String
    var fullUrl: String
    
    init(document: Document) {
        self.thumbnameUrl = document["thumbnameUrl"]!!.stringValue!
        self.fullUrl = document["fullUrl"]!!.stringValue!
        super.init()
    }
}
