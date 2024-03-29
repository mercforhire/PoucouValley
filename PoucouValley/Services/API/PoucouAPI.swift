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
    var app = App(id: AppSettingsManager.shared.getEnvironment().appID())
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
        if app.currentUser != nil {
            callBack(true)
            return
        }
        
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
    
    func restartRealm(callBack: @escaping(Bool) -> Void) {
        app = App(id: AppSettingsManager.shared.getEnvironment().appID())
        
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
            print("Uploading: \(progress.fractionCompleted)")
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
        let fileName = fileURL.components(separatedBy: s3RootURL).last
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
    
    func fetchPlans(callBack: @escaping(Result<ExplorePlansResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_explorePlans([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_explorePlans' and got result: \(document)")
                callBack(.success(ExplorePlansResponse(document: document)))
            }
        }
    }
    
    func searchPlans(keyword: String, callBack: @escaping(Result<SearchPlansResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["keyword": AnyBSON(keyword)]
        user.functions.api_searchPlans([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_searchPlans' and got result: \(document)")
                callBack(.success(SearchPlansResponse(document: document)))
            }
        }
    }
    
    func searchShops(keyword: String, category: BusinessCategories?, callBack: @escaping(Result<ExploreShopsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = [
            "keyword": AnyBSON(keyword),
            "category": category != nil ? AnyBSON(category!.rawValue) : AnyBSON.null
        ]
        user.functions.api_searchShops([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_searchShops' and got result: \(document)")
                callBack(.success(ExploreShopsResponse(document: document)))
            }
        }
    }
    
    func fetchShops(category: BusinessCategories?, callBack: @escaping(Result<ExploreShopsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        if let category = category {
            params["category"] = AnyBSON(category.rawValue)
        }
        user.functions.api_exploreShops([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_exploreShops' and got result: \(document)")
                callBack(.success(ExploreShopsResponse(document: document)))
            }
        }
    }
    
    func fetchFollowedShops(callBack: @escaping(Result<ExploreShopsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchFollowedShops([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_fetchFollowedShops' and got result: \(document)")
                callBack(.success(ExploreShopsResponse(document: document)))
            }
        }
    }
    
    func fetchMerchant(merchantId: ObjectId, callBack: @escaping(Result<FetchMerchantResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantId"] = AnyBSON(merchantId)
        
        user.functions.api_fetchMerchant([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_fetchMerchant' and got result: \(document)")
                callBack(.success(FetchMerchantResponse(document: document)))
            }
        }
    }
    
    func recordVisit(merchant: Merchant, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantId"] = AnyBSON(merchant.userId)
        
        user.functions.api_recordVisit([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_recordVisit' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func followMerchant(userId: ObjectId, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantId"] = AnyBSON(userId)
        
        user.functions.api_followMerchant([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_followMerchant' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func unfollowMerchant(userId: ObjectId, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantId"] = AnyBSON(userId)
        
        user.functions.api_unfollowMerchant([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_unfollowMerchant' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func fetchFollowShopStatus(merchant: Merchant, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantUserId"] = AnyBSON(merchant.userId)
        
        user.functions.api_fetchFollowShopStatus([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_fetchFollowShopStatus' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func fetchMerchantPlans(merchant: Merchant, callBack: @escaping(Result<ExplorePlansResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["merchantUserId"] = AnyBSON(merchant.userId)
        
        user.functions.api_fetchMerchantPlans([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_fetchMerchantPlans' and got result: \(document)")
                callBack(.success(ExplorePlansResponse(document: document)))
            }
        }
    }
    
    func fetchRelatedPlans(plan: Plan, callBack: @escaping(Result<ExplorePlansResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var params: Document = [:]
        params["planId"] = AnyBSON(plan.identifier)
        
        user.functions.api_fetchRelatedPlans([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_fetchRelatedPlans' and got result: \(document)")
                callBack(.success(ExplorePlansResponse(document: document)))
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
        user.functions.api_fetchGoals([]) { response, error in
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
                print("Called function 'api_fetchGoals' and got result: \(document)")
                callBack(.success(GetGoalsResponse(document: document)))
            }
        }
    }
    
    func fetchCompletedGoals(callBack: @escaping(Result<GetGoalsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchCompletedGoals([AnyBSON(apiKey)]) { response, error in
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
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["goalId": AnyBSON(goal.identifier)]
        user.functions.api_addAccomplishment([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
    
    func addAccomplishments(goals: [Goal], callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var goalIdsData: [AnyBSON] = []
        for goal in goals {
            goalIdsData.append(AnyBSON(goal.identifier))
        }
        let params: Document = ["goalIds": AnyBSON.array(goalIdsData)]
        user.functions.api_addAccomplishments([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addAccomplishments' and got result: \(document)")
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
        guard let apiKey = apiKey else { return }
        
        user.functions.api_updateCardholderInfo([AnyBSON(apiKey), AnyBSON(params.toDocument())]) { response, error in
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
        guard let apiKey = apiKey else { return }
        
        user.functions.api_updateMerchantInfo([AnyBSON(apiKey), AnyBSON(params.toDocument())]) { response, error in
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
    
    func fetchGifts(maxNumberOfResults: Int? = nil, callBack: @escaping(Result<FetchGiftsResponse, Error>) -> Void) {
        var params: [AnyBSON] = []
        if let maxNumberOfResults = maxNumberOfResults {
            params = [AnyBSON(maxNumberOfResults)]
        }
        user.functions.api_fetchGifts(params) { response, error in
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
                print("Called function 'api_fetchGifts' and got result: \(document)")
                callBack(.success(FetchGiftsResponse(document: document)))
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
    
    func fetchMerchantTransactions(callBack: @escaping(Result<FetchTransactionsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchMerchantTransactions([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_fetchMerchantTransactions' and got result: \(document)")
                callBack(.success(FetchTransactionsResponse(document: document)))
            }
        }
    }
    
    func fetchWallet(callBack: @escaping(Result<FetchWalletResponse, Error>) -> Void) {
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
                callBack(.success(FetchWalletResponse(document: document)))
            }
        }
    }
    
    func fetchPerformanceData(callBack: @escaping(Result<FetchPerformanceResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_fetchPerformanceData([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'fetchPerformanceData' and got result: \(document)")
                callBack(.success(FetchPerformanceResponse(document: document)))
            }
        }
    }
    
    func fetchVisitors(callBack: @escaping(Result<GetVisitorsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getVisitors([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getVisitors' and got result: \(document)")
                callBack(.success(GetVisitorsResponse(document: document)))
            }
        }
    }
    
    func fetchClientGroupsStatistics(callBack: @escaping(Result<FetchClientGroupsStatisticsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getClientGroupsStatistics([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getClientGroupsStatistics' and got result: \(document)")
                callBack(.success(FetchClientGroupsStatisticsResponse(document: document)))
            }
        }
    }
    
    func fetchClients(callBack: @escaping(Result<FetchClientsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getClients([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'getClientList' and got result: \(document)")
                callBack(.success(FetchClientsResponse(document: document)))
            }
        }
    }
    
    func fetchActivatedClients(callBack: @escaping(Result<FetchClientsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getActivatedClients([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getActivatedClients' and got result: \(document)")
                callBack(.success(FetchClientsResponse(document: document)))
            }
        }
    }
    
    func fetchFollowedClients(callBack: @escaping(Result<FetchClientsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getFollowedClients([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getActivatedClients' and got result: \(document)")
                callBack(.success(FetchClientsResponse(document: document)))
            }
        }
    }
    
    func fetchScannedClients(callBack: @escaping(Result<FetchClientsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getScannedClients([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getScannedClients' and got result: \(document)")
                callBack(.success(FetchClientsResponse(document: document)))
            }
        }
    }
    
    func fetchInputtedClients(callBack: @escaping(Result<FetchClientsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getInputtedClients([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getInputtedClients' and got result: \(document)")
                callBack(.success(FetchClientsResponse(document: document)))
            }
        }
    }
    
    func fetchClient(clientId: ObjectId, callBack: @escaping(Result<FetchClientResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["clientId": AnyBSON(clientId)]
                                
        user.functions.api_fetchClient([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_fetchClient' and got result: \(document)")
                callBack(.success(FetchClientResponse(document: document)))
            }
        }
    }
    
    func addClient(firstName: String = "", lastName: String = "", pronoun: String = "", gender: String = "", birthday: Birthday?, address: Address?, contact: Contact?, avatar: PVPhoto? = nil, company: String = "", jobTitle: String = "", hashtags: [String] = [], notes: String = "", email: String = "", callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var hashtagData: [AnyBSON] = []
        for tag in hashtags {
            hashtagData.append(AnyBSON(tag))
        }
        let params: Document = ["firstName": AnyBSON(firstName),
                                "lastName": AnyBSON(lastName),
                                "pronoun": AnyBSON(pronoun),
                                "gender": AnyBSON(gender),
                                "birthday": birthday != nil ? AnyBSON(birthday!.toDocument()) : AnyBSON.null,
                                "address": address != nil ? AnyBSON(address!.toDocument()) : AnyBSON.null,
                                "contact": contact != nil ? AnyBSON(contact!.toDocument()) : AnyBSON.null,
                                "avatar": avatar != nil ? AnyBSON(avatar!.toDocument()) : AnyBSON.null,
                                "company": AnyBSON(company),
                                "jobTitle": AnyBSON(jobTitle),
                                "hashtags": AnyBSON.array(hashtagData),
                                "notes": AnyBSON(notes),
                                "email": AnyBSON(email)]
        
        user.functions.api_addClient([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addClient' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func editClient(clientId: ObjectId, firstName: String? = nil, lastName: String? = nil, pronoun: String? = nil, gender: String? = nil, birthday: Birthday? = nil, address: Address? = nil, contact: Contact? = nil, avatar: PVPhoto? = nil, company: String? = nil, jobTitle: String? = nil, hashtags: [String]? = nil, notes: String? = nil, email: String? = nil, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        
        guard let apiKey = apiKey else { return }
        
        var hashtagData: [AnyBSON] = []
        for tag in hashtags ?? [] {
            hashtagData.append(AnyBSON(tag))
        }
        let params: Document = ["firstName": firstName != nil ? AnyBSON(firstName!) : AnyBSON.null,
                                "lastName": lastName != nil ? AnyBSON(lastName!) : AnyBSON.null,
                                "pronoun": pronoun != nil ? AnyBSON(pronoun!) : AnyBSON.null,
                                "gender": gender != nil ? AnyBSON(gender!) : AnyBSON.null,
                                "birthday": birthday != nil ? AnyBSON(birthday!.toDocument()) : AnyBSON.null,
                                "address": address != nil ? AnyBSON(address!.toDocument()) : AnyBSON.null,
                                "contact": contact != nil ? AnyBSON(contact!.toDocument()) : AnyBSON.null,
                                "avatar": avatar != nil ? AnyBSON(avatar!.toDocument()) : AnyBSON.null,
                                "company": company != nil ? AnyBSON(company!) : AnyBSON.null,
                                "jobTitle": jobTitle != nil ? AnyBSON(jobTitle!) : AnyBSON.null,
                                "hashtags": !hashtagData.isEmpty ? AnyBSON.array(hashtagData) : AnyBSON.null,
                                "notes": notes != nil ? AnyBSON(notes!) : AnyBSON.null,
                                "email": email != nil ? AnyBSON(email!) : AnyBSON.null]
        
        user.functions.api_editClient([AnyBSON(apiKey), AnyBSON(clientId), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_editClient' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func deleteClients(clients: [Client], callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let clientIds: [AnyBSON] = clients.map { client in
            return AnyBSON(client.identifier)
        }
        
        user.functions.api_deleteClients([AnyBSON(apiKey), AnyBSON.array(clientIds)]) { response, error in
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
                print("Called function 'api_deleteClients' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func scanCard(cardNumber: String, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["cardNumber": AnyBSON(cardNumber)]
        
        user.functions.api_scanCard([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_scanCard' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func redeemGift(gift: Gift, callBack: @escaping(Result<TransactionResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["giftId": AnyBSON(gift.identifier)]
        
        user.functions.api_redeemGift([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_redeemGift' and got result: \(document)")
                callBack(.success(TransactionResponse(document: document)))
            }
        }
    }
    
    func addPlan(title: String, description: String, photos: [PVPhoto], price: Double?, discountedPrice: Double?, hashtags: [String]?, callBack: @escaping(Result<AddPlanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var photosData: [AnyBSON] = []
        for photo in photos {
            photosData.append(AnyBSON(photo.toDocument()))
        }
        var hashtagData: [AnyBSON] = []
        for tag in hashtags ?? [] {
            hashtagData.append(AnyBSON(tag))
        }
        
        let params: Document = ["title": AnyBSON(title),
                                "description": AnyBSON(description),
                                "photos": AnyBSON.array(photosData),
                                "price": price != nil ? AnyBSON(price!) : AnyBSON.null,
                                "discountedPrice": discountedPrice != nil ? AnyBSON(discountedPrice!) : AnyBSON.null,
                                "hashtags": !hashtagData.isEmpty ? AnyBSON.array(hashtagData) : AnyBSON.null]
        
        user.functions.api_addPlan([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addPlan' and got result: \(document)")
                callBack(.success(AddPlanResponse(document: document)))
            }
        }
    }
    
    func editPlan(plan: Plan, title: String, description: String, photos: [PVPhoto], price: Double?, discountedPrice: Double?, hashtags: [String]?, callBack: @escaping(Result<AddPlanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        var photosData: [AnyBSON] = []
        for photo in photos {
            photosData.append(AnyBSON(photo.toDocument()))
        }
        var hashtagData: [AnyBSON] = []
        for tag in hashtags ?? [] {
            hashtagData.append(AnyBSON(tag))
        }
        
        let params: Document = ["title": AnyBSON(title),
                                "description": AnyBSON(description),
                                "photos": AnyBSON.array(photosData),
                                "price": price != nil ? AnyBSON(price!) : AnyBSON.null,
                                "discountedPrice": discountedPrice != nil ? AnyBSON(discountedPrice!) : AnyBSON.null,
                                "hashtags": !hashtagData.isEmpty ? AnyBSON.array(hashtagData) : AnyBSON.null]
        
        user.functions.api_editPlan([AnyBSON(apiKey), AnyBSON(plan.identifier), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_editPlan' and got result: \(document)")
                callBack(.success(AddPlanResponse(document: document)))
            }
        }
    }
    
    func logout(callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_logOut([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_logOut' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func deleteAccount(reason: String, callBack: @escaping(Result<StringResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["reason": AnyBSON(reason)]
        user.functions.api_deleteAccount([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_deleteAccount' and got result: \(document)")
                callBack(.success(StringResponse(document: document)))
            }
        }
    }
    
    func registerDeviceToken(deviceToken: String, callBack: @escaping(Result<StringArrayResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["deviceToken": AnyBSON(deviceToken)]
        user.functions.api_registerDeviceToken([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_registerDeviceToken' and got result: \(document)")
                callBack(.success(StringArrayResponse(document: document)))
            }
        }
    }
    
    func unregisterDeviceToken(deviceToken: String, callBack: @escaping(Result<StringArrayResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["deviceToken": AnyBSON(deviceToken)]
        user.functions.api_unregisterDeviceToken([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_unregisterDeviceToken' and got result: \(document)")
                callBack(.success(StringArrayResponse(document: document)))
            }
        }
    }
    
    func fetchMerchantCards(callBack: @escaping(Result<CardsResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        user.functions.api_getMerchantCards([AnyBSON(apiKey)]) { response, error in
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
                print("Called function 'api_getMerchantCards' and got result: \(document)")
                callBack(.success(CardsResponse(document: document)))
            }
        }
    }
    
    func addCardToMerchant(cardNumber: String, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["cardNumber": AnyBSON(cardNumber)]
        user.functions.api_addCardToMerchant([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_addCardToMerchant' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
    
    func setUserSettings(notification: NotificationSettings, callBack: @escaping(Result<BooleanResponse, Error>) -> Void) {
        guard let apiKey = apiKey else { return }
        
        let params: Document = ["notification": AnyBSON(notification.rawValue)]
        user.functions.api_setUserSettings([AnyBSON(apiKey), AnyBSON(params)]) { response, error in
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
                print("Called function 'api_setUserSettings' and got result: \(document)")
                callBack(.success(BooleanResponse(document: document)))
            }
        }
    }
}
