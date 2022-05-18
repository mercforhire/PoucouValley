//
//  GetStartedSteps.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class GetStartedSteps: Object {
    var step: Int = 0
    var text: List<String> = List()
    
    convenience init(document: Document) {
        self.init()
        
        self.step = document["step"]!!.asInt()!
        let text: List<String> = List()
        for string in document["text"]!!.arrayValue! {
            text.append(string!.stringValue!)
        }
        self.text = text
    }
}
