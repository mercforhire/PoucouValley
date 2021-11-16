//
//  Location.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import Foundation

struct UnsplashUrls: Codable {
    var raw: String
    var full: String
    var regular: String
    var small: String
    var thumb: String
}

struct UnsplashLink: Codable {
    var selfLink: String
    var html: String
    var download: String
    var download_location: String
    
    enum CodingKeys: String, CodingKey {
        case selfLink = "self"
        case html
        case download
        case download_location
    }
}

struct UnsplashProfileImage: Codable {
    var small: String
    var medium: String
    var large: String
}

struct UnsplashUser: Codable {
    var identifier: String
    var updated_at: String?
    var username: String?
    var name: String?
    var first_name: String?
    var last_name: String?
    var twitter_username: String?
    var portfolio_url: String?
    var bio: String?
    var location: String?
    var profile_image: UnsplashProfileImage?
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case updated_at
        case username
        case name
        case first_name
        case last_name
        case twitter_username
        case portfolio_url
        case bio
        case location
        case profile_image
    }
}

struct UnsplashPhoto: Codable {
    var identifier: String
    var created_at: String
    var updated_at: String
    var width: Int
    var height: Int
    var description: String?
    var alt_description: String?
    var urls: UnsplashUrls
    var links: UnsplashLink
    var user: UnsplashUser
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case created_at
        case updated_at
        case width
        case height
        case description
        case alt_description
        case urls
        case links
        case user
    }
}

struct UnsplashTopic: Codable {
    var identifier: String
    var slug: String
    var title: String
    var description: String
    var published_at: String
    var updated_at: String
    var starts_at: String
    var cover_photo: UnsplashPhoto
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case slug
        case title
        case description
        case published_at
        case updated_at
        case starts_at
        case cover_photo
    }
}

struct UnsplashCollection: Codable {
    var identifier: String
    var title: String
    var description: String
    var published_at: String
    var last_collected_at: String
    var updated_at: String
    var total_photos: Int
    var cover_photo: UnsplashPhoto
    var user: UnsplashUser
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case title
        case description
        case published_at
        case last_collected_at
        case updated_at
        case total_photos
        case cover_photo
        case user
    }
}
