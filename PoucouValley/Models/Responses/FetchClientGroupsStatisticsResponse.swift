//
//  FetchClientGroupsStatisticsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-18.
//

import UIKit
import RealmSwift

class FetchClientGroupsStatisticsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: GroupsStatistics?
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let data = document["data"]??.documentValue {
            self.data = GroupsStatistics(document: data)
        }
    }
}
