//
//  PhotoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import Foundation

struct PhotoResponse: Codable {
    var photoName: String
    var photoUrl: String
    var thumbnailName: String
    var thumbnailUrl: String
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["photoName"] = photoName
        params["photoUrl"] = photoUrl
        params["thumbnailName"] = thumbnailName
        params["thumbnailUrl"] = thumbnailUrl
        return params
    }
}
