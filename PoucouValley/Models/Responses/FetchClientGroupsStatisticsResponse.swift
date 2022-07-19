//
//  FetchClientGroupsStatisticsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-07-18.
//

import UIKit
import RealmSwift

class GroupsStatistics: BaseEmbeddedObject {
    var activatedClients: Int = 0
    var totalCards: Int = 0
    var followedClients: Int = 0
    var inputtedClients: Int = 0
    var scannedClients: Int = 0
    
    convenience init(document: Document) {
        self.init()
        self.activatedClients = document["ACTIVATED_CLIENTS"]!!.asInt()!
        self.totalCards = document["TOTAL_CARDS"]!!.asInt()!
        self.followedClients = document["FOLLOWED_CLIENTS"]!!.asInt()!
        self.inputtedClients = document["INPUTTED_CLIENTS"]!!.asInt()!
        self.scannedClients = document["SCANNED_CLIENTS"]!!.asInt()!
    }
}

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
