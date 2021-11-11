//
//  AuthenticationService.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation
import Alamofire

class PoucouAPI {
    static let shared = PoucouAPI()
    
    var baseURL = "https://api.unsplash.com/"
    let service: NetworkService
    
    init() {
        self.service = NetworkService()
    }
    
    func getPhotos(callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 50, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getPhotos.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getPhotos.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getStories(callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 50, "order_by": "latest", "page": 2]
        let url = baseURL + APIRequestURLs.getPhotos.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getPhotos.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getGiftcards(callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 20, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getGiftcards.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getGiftcards.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getRandomAvatar(callBack: @escaping(Result<UnsplashPhoto?, AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 100, "order_by": "latest"]
        let url = baseURL + APIRequestURLs.getAvatars.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getAvatars.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response.randomElement()))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
}
