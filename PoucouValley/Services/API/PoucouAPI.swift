//
//  AuthenticationService.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation
import Alamofire
import RealmSwift
import Realm

enum RealmError: Error {
    case decodingError
}

class PoucouAPI {
    static let shared = PoucouAPI()
    
    var baseURL = "https://api.unsplash.com/"
    let service: NetworkService
    var realm: Realm!
    let app = App(id: AppSettingsManager.shared.getEnvironment().appID())
    var user: RLMUser {
        return app.currentUser!
    }
    var apiKey: String?
    
    init() {
        self.service = NetworkService()
        do {
            self.realm = try Realm()
        } catch {
            try? FileManager.default.removeItem(at: Realm.Configuration.defaultConfiguration.fileURL!)
            self.realm = try! Realm()
        }
    }
    
    func initRealm(callBack: @escaping(Bool) -> Void) {
        // Log in anonymously.
        app.login(credentials: Credentials.anonymous) { (result) in
            // Remember to dispatch back to the main thread in completion handlers
            // if you want to do anything on the UI.
            DispatchQueue.main.async {
                switch result {
                case .failure(let error):
                    print("Login failed: \(error)")
                    callBack(false)
                case .success(let user):
                    print("Login as \(user) succeeded!")
                    // Continue below
                    callBack(true)
                }
            }
        }
    }
    
    func getPhotos(page: Int, callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 25, "order_by": "latest", "page": page]
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
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 10, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getStories.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getStories.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
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
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 10, "order_by": "latest", "page": 1]
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
    
    func getDeals(callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 20, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getDeals.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getDeals.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getStores(callBack: @escaping(Result<[UnsplashPhoto], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 20, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getStores.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getStores.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashPhoto]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getCommonKeywords(callBack: @escaping(Result<[UnsplashTopic], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 20, "order_by": "latest", "page": 1]
        let url = baseURL + APIRequestURLs.getCommonKeywords.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getCommonKeywords.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashTopic]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getCategories(callBack: @escaping(Result<[UnsplashTopic], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ", "per_page": 20, "order_by": "latest", "page": 2]
        let url = baseURL + APIRequestURLs.getCommonKeywords.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.getCommonKeywords.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<[UnsplashTopic]>) in
            switch result {
            case .success(let response):
                callBack(.success(response))
            case .failure(let error):
                callBack(.failure(error))
                print ("Error occured \(error)")
            }
        }
    }
    
    func getSearchCollections(query: String, callBack: @escaping(Result<[UnsplashSearchResult], AFError>) -> Void) {
        let params: [String : Any] = ["client_id": "S7r_wj5LDB-aPbhupkBM5DEfdGQXcfViXQCCSXcDUCQ",
                                      "per_page": 20,
                                      "order_by": "latest",
                                      "page": 1,
                                      "query": query]
        let url = baseURL + APIRequestURLs.search.rawValue
        
        service.httpRequest(url: url, method: APIRequestURLs.search.getHTTPMethod(), parameters: params, headers: Headers.defaultHeader()) { (result: AFResult<UnsplashSearchCollectionsResponse>) in
            switch result {
            case .success(let response):
                callBack(.success(response.results))
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
    
    func fetchGetStartedSteps(callBack: @escaping(Result<GetStartedStepsResponse, Error>) -> Void) {
        user.functions.api_fetchGetStartedSteps([]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_fetchGetStartedSteps' and got result: \(document)")
                callBack(.success(GetStartedStepsResponse(document: document)))
            }
        }
    }
    
    func sendEmailCode(email: String, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        user.functions.api_sendEmailCode([AnyBSON(email)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_sendEmailCode' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func checkLoginEmail(email: String, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        user.functions.api_checkLoginEmail([AnyBSON(email)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_checkLoginEmail' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func checkRegisterEmail(email: String, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        user.functions.api_checkRegisterEmail([AnyBSON(email)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_checkRegisterEmail' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func login(email: String, code: String, callBack: @escaping(Result<LoginResponse, Error>) -> Void) {
        user.functions.api_login([AnyBSON(email), AnyBSON(code)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_login' and got result: \(document)")
                callBack(.success(LoginResponse(document: document)))
            }
        }
    }
    
    func loginByCard(cardNumber: String, code: String, callBack: @escaping(Result<LoginResponse, Error>) -> Void) {
        user.functions.api_loginByCard([AnyBSON(cardNumber), AnyBSON(code)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_loginByCard' and got result: \(document)")
                callBack(.success(LoginResponse(document: document)))
            }
        }
    }
    
    func loginByAPIKey(loginKey: String, callBack: @escaping(Result<LoginResponse, Error>) -> Void) {
        user.functions.api_loginByAPIKey([AnyBSON(loginKey)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_loginByAPIKey' and got result: \(document)")
                callBack(.success(LoginResponse(document: document)))
            }
        }
    }
    
    func register(email: String, code: String, userType: UserType, callBack: @escaping(Result<LoginResponse, Error>) -> Void) {
        user.functions.api_register([AnyBSON(email), AnyBSON(code)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_login' and got result: \(document)")
                callBack(.success(LoginResponse(document: document)))
            }
        }
    }
    
    func registerByCard(cardNumber: String, code: String, email: String, callBack: @escaping(Result<LoginResponse, Error>) -> Void) {
        user.functions.api_registerByCard([AnyBSON(cardNumber), AnyBSON(code), AnyBSON(email)]) { response, error in
            DispatchQueue.main.async {
                guard error == nil else {
                    print("Function call failed: \(error!.localizedDescription)")
                    callBack(.failure(error!))
                    return
                }
                guard case let .document(document) = response else {
                    print("Unexpected non-string result: \(response ?? "nil")")
                    callBack(.failure(RealmError.decodingError))
                    return
                }
                print("Called function 'api_registerByCard' and got result: \(document)")
                callBack(.success(LoginResponse(document: document)))
            }
        }
    }
    
    func logout(callBack: @escaping(Bool) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_logOut([AnyBSON(apiKey)]) { response, error in
            guard error == nil else {
                print("Function call failed: \(error!.localizedDescription)")
                return
            }
            guard case let .string(document) = response else {
                print("Unexpected non-string result: \(response ?? "nil")")
                return
            }
            print("Called function 'api_logOut' and got result: \(document)")
        }
    }
}
