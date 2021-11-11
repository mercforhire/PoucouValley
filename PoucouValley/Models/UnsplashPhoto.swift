//
//  Location.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-18.
//

import Foundation

/*
 {
         "id": "Qrjx2nTBHVo",
         "created_at": "2020-07-01T18:30:14-04:00",
         "updated_at": "2021-11-06T20:17:26-04:00",
         "promoted_at": null,
         "width": 6016,
         "height": 4016,
         "color": "#a6a6a6",
         "blur_hash": "LSJbHbIAIU%L_N%LRQxut7IUtRoM",
         "description": null,
         "alt_description": "silver laptop on brown wooden table",
         "urls": {
             "raw": "https://images.unsplash.com/photo-1593642532009-6ba71e22f468?ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ&ixlib=rb-1.2.1",
             "full": "https://images.unsplash.com/photo-1593642532009-6ba71e22f468?crop=entropy&cs=srgb&fm=jpg&ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ&ixlib=rb-1.2.1&q=85",
             "regular": "https://images.unsplash.com/photo-1593642532009-6ba71e22f468?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ&ixlib=rb-1.2.1&q=80&w=1080",
             "small": "https://images.unsplash.com/photo-1593642532009-6ba71e22f468?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ&ixlib=rb-1.2.1&q=80&w=400",
             "thumb": "https://images.unsplash.com/photo-1593642532009-6ba71e22f468?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ&ixlib=rb-1.2.1&q=80&w=200"
         },
         "links": {
             "self": "https://api.unsplash.com/photos/Qrjx2nTBHVo",
             "html": "https://unsplash.com/photos/Qrjx2nTBHVo",
             "download": "https://unsplash.com/photos/Qrjx2nTBHVo/download?ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ",
             "download_location": "https://api.unsplash.com/photos/Qrjx2nTBHVo/download?ixid=MnwyNzM5MTB8MXwxfGFsbHwxfHx8fHx8Mnx8MTYzNjMxNDk1OQ"
         },
         "categories": [],
         "likes": 804,
         "liked_by_user": false,
         "current_user_collections": [],
         "sponsorship": {
             "impression_urls": [
                 "https://ad.doubleclick.net/ddm/trackimp/N1153793.3286893UNSPLASH/B26742675.318699742;dc_trk_aid=511264654;dc_trk_cid=160420310;ord=[timestamp];dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;tfua=;gdpr=${GDPR};gdpr_consent=${GDPR_CONSENT_755};ltd=?",
                 "https://tps.doubleverify.com/visit.jpg?ctx=569086&cmp=26742675&sid=6781114&plc=318699742&adsrv=1&btreg=&btadsrv=&crt=&tagtype=&dvtagver=6.1.img&",
                 "https://secure.insightexpressai.com/adServer/adServerESI.aspx?script=false&bannerID=9537089&rnd=[timestamp]&gdpr=&gdpr_consent=&redir=https://secure.insightexpressai.com/adserver/1pixel.gif",
                 "https://secure.insightexpressai.com/adServer/adServerESI.aspx?script=false&bannerID=9541344&rnd=[timestamp]&redir=https://secure.insightexpressai.com/adserver/1pixel.gif"
             ],
             "tagline": "Designed to be the Best",
             "tagline_url": "https://ad.doubleclick.net/ddm/trackclk/N1153793.3286893UNSPLASH/B26742675.318699742;dc_trk_aid=511264654;dc_trk_cid=160420310;dc_lat=;dc_rdid=;tag_for_child_directed_treatment=;tfua=;ltd=",
             "sponsor": {
                 "id": "2DC3GyeqWjI",
                 "updated_at": "2021-11-07T14:22:09-05:00",
                 "username": "xps",
                 "name": "XPS",
                 "first_name": "XPS",
                 "last_name": null,
                 "twitter_username": "Dell",
                 "portfolio_url": "http://www.dell.com/xps",
                 "bio": "Designed to be the best, with cutting edge technologies, exceptional build quality, unique materials and powerful features.",
                 "location": null,
                 "links": {
                     "self": "https://api.unsplash.com/users/xps",
                     "html": "https://unsplash.com/@xps",
                     "photos": "https://api.unsplash.com/users/xps/photos",
                     "likes": "https://api.unsplash.com/users/xps/likes",
                     "portfolio": "https://api.unsplash.com/users/xps/portfolio",
                     "following": "https://api.unsplash.com/users/xps/following",
                     "followers": "https://api.unsplash.com/users/xps/followers"
                 },
                 "profile_image": {
                     "small": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32",
                     "medium": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64",
                     "large": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128"
                 },
                 "instagram_username": "dell",
                 "total_collections": 0,
                 "total_likes": 0,
                 "total_photos": 22,
                 "accepted_tos": true,
                 "for_hire": false,
                 "social": {
                     "instagram_username": "dell",
                     "portfolio_url": "http://www.dell.com/xps",
                     "twitter_username": "Dell",
                     "paypal_email": null
                 }
             }
         },
         "topic_submissions": {
             "technology": {
                 "status": "approved",
                 "approved_on": "2020-09-21T13:39:53-04:00"
             }
         },
         "user": {
             "id": "2DC3GyeqWjI",
             "updated_at": "2021-11-07T14:22:09-05:00",
             "username": "xps",
             "name": "XPS",
             "first_name": "XPS",
             "last_name": null,
             "twitter_username": "Dell",
             "portfolio_url": "http://www.dell.com/xps",
             "bio": "Designed to be the best, with cutting edge technologies, exceptional build quality, unique materials and powerful features.",
             "location": null,
             "links": {
                 "self": "https://api.unsplash.com/users/xps",
                 "html": "https://unsplash.com/@xps",
                 "photos": "https://api.unsplash.com/users/xps/photos",
                 "likes": "https://api.unsplash.com/users/xps/likes",
                 "portfolio": "https://api.unsplash.com/users/xps/portfolio",
                 "following": "https://api.unsplash.com/users/xps/following",
                 "followers": "https://api.unsplash.com/users/xps/followers"
             },
             "profile_image": {
                 "small": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=32&w=32",
                 "medium": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=64&w=64",
                 "large": "https://images.unsplash.com/profile-1600096866391-b09a1a53451aimage?ixlib=rb-1.2.1&q=80&fm=jpg&crop=faces&cs=tinysrgb&fit=crop&h=128&w=128"
             },
             "instagram_username": "dell",
             "total_collections": 0,
             "total_likes": 0,
             "total_photos": 22,
             "accepted_tos": true,
             "for_hire": false,
             "social": {
                 "instagram_username": "dell",
                 "portfolio_url": "http://www.dell.com/xps",
                 "twitter_username": "Dell",
                 "paypal_email": null
             }
         }
     }
 */
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
