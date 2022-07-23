//
//  GetStartedSteps.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-16.
//

import Foundation
import RealmSwift

class GetStartedSteps: BaseObject {
    var step: Int = 0
    var image: String = ""
    var text: List<String> = List()
    
    convenience init(document: Document) {
        self.init()
        
        self.step = document["step"]!!.asInt()!
        self.image = document["image"]!!.stringValue!
        
        let text: List<String> = List()
        for string in document["text"]!!.arrayValue! {
            text.append(string!.stringValue!)
        }
        self.text = text
    }
}
