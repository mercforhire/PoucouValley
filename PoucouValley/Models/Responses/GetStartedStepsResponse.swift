//
//  GetStartedSteps.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-20.
//

import Foundation
import RealmSwift

class GetStartedStepsResponse: Object {
    var success: Bool
    var message: String
    var data: List<GetStartedSteps>?
    
    init(document: Document) {
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let steps = document["data"]??.arrayValue {
            let data: List<GetStartedSteps> = List()
            for step in steps {
                data.append(GetStartedSteps(document: step!.documentValue!))
            }
            self.data = data
        }
        super.init()
    }
}

