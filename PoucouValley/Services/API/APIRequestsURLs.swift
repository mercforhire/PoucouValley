//
//  APIRequestsURLs.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-06-28.
//

import Foundation
import Alamofire

enum APIRequestURLs: String {
    case getPhotos = "photos/"
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .getPhotos:
            return .get
        }
    }
    
    static func needAuthToken(url: String) -> Bool {
        return true
    }
}
