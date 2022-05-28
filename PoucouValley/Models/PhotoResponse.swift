//
//  PhotoResponse.swift
//  CupidLove
//
//  Created by Leon Chen on 2022-02-12.
//

import Foundation

struct PhotoResponse: Codable {
    var fullsizeName: String
    var thumbnailName: String
    
    var fullsizeUrl: String
    var thumbnailUrl: String
    
    func params() -> [String: Any] {
        var params: [String: Any] = [:]
        params["thumbnailName"] = thumbnailName
        params["fullsizeName"] = fullsizeName
        
        params["fullsizeUrl"] = fullsizeUrl
        params["thumbnailUrl"] = thumbnailUrl
        return params
    }
}
