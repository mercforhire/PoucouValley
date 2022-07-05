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
import AWSS3
import AWSCore

enum RealmError: Error {
    case decodingError
}

typealias progressBlock = (_ progress: Double) -> Void
typealias completionBlock = (_ response: Any?, _ error: Error?) -> Void

class PoucouAPI {
    static let shared = PoucouAPI()
    
    var environment: Environments {
        return AppSettingsManager.shared.getEnvironment()
    }
    
    var baseURL: String {
        return environment.hostUrl()
    }
    
    var s3RootURL: String {
        return environment.s3RootURL()
    }
    
    var bucketName: String {
        return environment.bucketName()
    }
    
    var s3Key: String {
        return environment.s3Key()
    }
    
    var accessKey: String {
        return environment.accessKey()
    }
    
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
        initializeS3()
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
    
    func initializeS3() {
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: s3Key, secretKey: accessKey)
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func uploadS3file(fileUrl: URL, fileName: String, progress: progressBlock?, completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?) {
        let expression  = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task: AWSS3TransferUtilityTask, progress: Progress) -> Void in
            print("Downloading: \(progress.fractionCompleted)")
            if progress.isFinished {
                print("Upload Finished...")
            }
        }
        
        expression.setValue("public-read-write", forRequestHeader: "x-amz-acl")
        expression.setValue("public-read-write", forRequestParameter: "x-amz-acl")
        
        AWSS3TransferUtility.default().uploadFile(fileUrl, bucket: bucketName, key: fileName, contentType: "image/jpg", expression: expression, completionHandler: completionHandler).continueWith(block: { task in
            if task.error != nil {
                print("Error uploading file: \(String(describing: task.error?.localizedDescription))")
            }
            if task.result != nil {
                print("Starting upload...")
            }
            return nil
        })
    }
    
    func deleteS3file(fileURL: String, progress: progressBlock?, completion: completionBlock?) {
        let fileName = (fileURL as NSString).lastPathComponent
        let request = AWSS3DeleteObjectRequest()!
        request.bucket = bucketName
        request.key = fileName
        
        let s3Service = AWSS3.default()
        s3Service.deleteObject(request).continueWith { task in
            if let error = task.error {
                print("Error occurred: \(error)")
                completion?(task.result, error)
                return nil
            }
            print("Bucket deleted successfully.")
            completion?(task.result, nil)
            return nil
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
    
    func fetchBusinessTypes(callBack: @escaping(Result<GetBusinessTypesResponse, Error>) -> Void) {
        user.functions.api_getBusinessTypes([]) { response, error in
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
                print("Called function 'api_getBusinessTypes' and got result: \(document)")
                callBack(.success(GetBusinessTypesResponse(document: document)))
            }
        }
    }
    
    func fetchGoals(callBack: @escaping(Result<GetGoalsResponse, Error>) -> Void) {
        user.functions.api_getBusinessTypes([]) { response, error in
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
                print("Called function 'api_getBusinessTypes' and got result: \(document)")
                callBack(.success(GetGoalsResponse(document: document)))
            }
        }
    }
    
    func fetchCompletedGoals(callBack: @escaping(Result<GetGoalsResponse, Error>) -> Void) {
        user.functions.api_fetchCompletedGoals([]) { response, error in
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
                print("Called function 'api_fetchCompletedGoals' and got result: \(document)")
                callBack(.success(GetGoalsResponse(document: document)))
            }
        }
    }
    
    func addAccomplishment(goal: Goal, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        let params: Document = ["goalId": AnyBSON(goal.identifier)]
        user.functions.api_addAccomplishment([AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addAccomplishment' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func fetchPoucouCardBulletPoints(callBack: @escaping(Result<GetPoucouCardBulletPointsResponse, Error>) -> Void) {
        user.functions.api_getPoucouCardBulletPoints([]) { response, error in
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
                print("Called function 'api_getPoucouCardBulletPoints' and got result: \(document)")
                callBack(.success(GetPoucouCardBulletPointsResponse(document: document)))
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
    
    func checkCardAvailable(cardNumber: String, code: String, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        user.functions.api_checkCardAvailable([AnyBSON(cardNumber), AnyBSON(code)]) { response, error in
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
                print("Called function 'api_checkCardAvailable' and got result: \(document)")
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
        user.functions.api_register([AnyBSON(email), AnyBSON(code), AnyBSON(userType.rawValue)]) { response, error in
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
    
    func updateCardholderInfo(params: UpdateCardholderInfoParams, callBack: @escaping(Result<UpdateCardholderResponse, Error>) -> Void) {
        user.functions.api_updateCardholderInfo(params.params()) { response, error in
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
                print("Called function 'api_updateCardholderInfo' and got result: \(document)")
                callBack(.success(UpdateCardholderResponse(document: document)))
            }
        }
    }
    
    func updateMerchantInfo(params: UpdateMerchantInfoParams, callBack: @escaping(Result<UpdateMerchantResponse, Error>) -> Void) {
        user.functions.api_updateMerchantInfo(params.params()) { response, error in
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
                print("Called function 'api_updateMerchantInfo' and got result: \(document)")
                callBack(.success(UpdateMerchantResponse(document: document)))
            }
        }
    }
    
    func fetchMyCard(callBack: @escaping (Result<FetchMyCardResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchMyCard([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_fetchMyCard' and got result: \(document)")
                callBack(.success(FetchMyCardResponse(document: document)))
            }
        }
    }
    
    func addCardToCardholder(cardNumber: String, pin: String, callBack: @escaping(Result<UpdateCardholderResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["cardNumber": AnyBSON(cardNumber), "cardPin": AnyBSON(pin)]
        user.functions.api_addCardToCardholder([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addCardToCardholder' and got result: \(document)")
                callBack(.success(UpdateCardholderResponse(document: document)))
            }
        }
    }
    
    func fetchTransactions(callBack: @escaping(Result<FetchTransactionsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchTransactions([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_fetchTransactions' and got result: \(document)")
                callBack(.success(FetchTransactionsResponse(document: document)))
            }
        }
    }
    
    func fetchWallet(callBack: @escaping(Result<FetchTransactionsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchWallet([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_fetchWallet' and got result: \(document)")
                callBack(.success(FetchTransactionsResponse(document: document)))
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
