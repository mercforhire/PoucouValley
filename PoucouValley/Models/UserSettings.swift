//
//  UserSettings.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-11.
//

import Foundation
import RealmSwift

class UserSettings: BaseEmbeddedObject {
    var notification: NotificationSettings?
    
    convenience init(document: Document) {
        self.init()
        self.notification = NotificationSettings(rawValue: document["notification"]!!.stringValue!) ?? .all
    }
}
