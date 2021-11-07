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
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ"]
        let url = baseURL + APIRequestURLs.getPhotos.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.signInWithEmail.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<TokenResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
}
