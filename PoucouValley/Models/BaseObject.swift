//
//  BaseObject.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-18.
//

import UIKit
import RealmSwift

class BaseObject: Object {
    @objc dynamic var sample : String? = nil
}

class BaseEmbeddedObject: EmbeddedObject {
    @objc dynamic var sample : String? = nil
}
