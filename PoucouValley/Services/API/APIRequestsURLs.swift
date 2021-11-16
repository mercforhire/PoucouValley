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
    case getStories = "collections/8510889/photos/"
    case getAvatars = "collections/ser5GKYWYJo/photos/"
    case getGiftcards = "collections/4529392/photos/"
    case getCommonKeywords = "topics/"
    case getDeals = "collections/6763707/photos/"
    case getStores = "collections/1418918/photos/"
    case search = "/search/collections"
    
    func getHTTPMethod() -> HTTPMethod {
        switch self {
        case .getStories, .getPhotos, .getAvatars, .getGiftcards, .getCommonKeywords, .getDeals, .getStores, .search:
            return .get
        }
    }
    
    static func needAuthToken(url: String) -> Bool {
        return true
    }
}
