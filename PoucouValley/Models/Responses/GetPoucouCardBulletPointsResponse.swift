//
//  GetPoucouCardBulletPointsResponse.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-05-24.
//

import Foundation
import RealmSwift

class GetPoucouCardBulletPointsResponse: BaseObject {
    var success: Bool = false
    var message: String = ""
    var data: List<PoucouCardBulletPoint> = List()
    
    convenience init(document: Document) {
        self.init()
        self.success = document["success"]!!.boolValue!
        self.message = document["message"]!!.stringValue!
        if let points = document["data"]??.arrayValue {
            let data: List<PoucouCardBulletPoint> = List()
            for point in points {
                data.append(PoucouCardBulletPoint(document: point!.documentValue!))
            }
            self.data = data
        }
    }
}
