//
//  UserManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-27.
//

import Foundation
import Valet
import Toucan
import RealmSwift

class UserManager {
    var user: UserDetails? {
        didSet {
            guard let user = user?.user else {
                api.apiKey = nil
                saveLoginInfo()
                return
            }
            
            api.apiKey = user.apiKey
            saveLoginInfo()
        }
    }
    
    static let shared = UserManager()
    
    private let myValet = Valet.valet(with: Identifier(nonEmpty: "CPLove")!, accessibility: .whenUnlocked)
    private var api: PoucouAPI {
        return PoucouAPI.shared
    }
    
    init() {
        // demo code:
        api.apiKey = "35d4400a0722290fd669bbd8b3dae042bae43339193cfe7d6816f9a448664fcfdcb90a1e1e1edfb9210a7e926d81afead1c95bdf9eae6079a6d9e64a574be555"
//        if let apiKey = try? myValet.string(forKey: "apiKey") {
//            api.apiKey = apiKey
//        }
    }
    
    func isLoggedIn() -> Bool {
        return !(api.apiKey?.isEmpty ?? true)
    }
    
    func loginUsingApiKey(completion: @escaping (Bool) -> Void) {
        guard let apiKey = api.apiKey else { return }
        
        api.loginByAPIKey(loginKey: apiKey) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else if response.message == ResponseMessages.userDoesNotExist.rawValue {
                    showErrorDialog(error: ResponseMessages.userDoesNotExist.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.userAlreadyDeletedAccount.rawValue {
                    showErrorDialog(error: ResponseMessages.userAlreadyDeletedAccount.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error.")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func login(email: String, code: String, completion: @escaping (Bool) -> Void) {
        api.login(email: email, code: code) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else if response.message == ResponseMessages.validationCodeInvalid.rawValue {
                    showErrorDialog(error: ResponseMessages.validationCodeInvalid.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.userAlreadyDeletedAccount.rawValue {
                    showErrorDialog(error: ResponseMessages.userAlreadyDeletedAccount.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func loginWithCard(cardNumber: String, code: String, completion: @escaping (Bool) -> Void) {
        api.loginByCard(cardNumber: cardNumber, code: code) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else if response.message == ResponseMessages.cardPinIncorrect.rawValue {
                    showErrorDialog(error: ResponseMessages.cardPinIncorrect.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.userAlreadyDeletedAccount.rawValue {
                    showErrorDialog(error: ResponseMessages.userAlreadyDeletedAccount.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func register(email: String, code: String, userType: UserType, completion: @escaping (Bool) -> Void) {
        api.register(email: email, code: code, userType: userType) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else if response.message == ResponseMessages.emailAlreadyExist.rawValue {
                    showErrorDialog(error: ResponseMessages.emailAlreadyExist.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.validationCodeInvalid.rawValue {
                    showErrorDialog(error: ResponseMessages.validationCodeInvalid.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func register(cardNumber: String, code: String, email: String, completion: @escaping (Bool) -> Void) {
        api.registerByCard(cardNumber: cardNumber, code: code, email: email) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else if response.message == ResponseMessages.cardholderAlreadyExist.rawValue {
                    showErrorDialog(error: ResponseMessages.cardholderAlreadyExist.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.emailAlreadyExist.rawValue {
                    showErrorDialog(error: ResponseMessages.emailAlreadyExist.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.cardPinIncorrect.rawValue {
                    showErrorDialog(error: ResponseMessages.cardPinIncorrect.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func addCardToCardholder(cardNumber: String, pin: String, completion: @escaping(Bool) -> Void) {
        api.addCardToCardholder(cardNumber: cardNumber, pin: pin, callBack: { [weak self] result in
            switch result {
            case .success(let response):
                if response.success, let cardholder = response.data {
                    self?.user?.cardholder = cardholder
                    completion(true)
                } else if response.message == ResponseMessages.cardholderNotFound.rawValue {
                    showErrorDialog(error: ResponseMessages.cardholderNotFound.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.cardAlreadyUsed.rawValue {
                    showErrorDialog(error: ResponseMessages.cardAlreadyUsed.errorMessage())
                    completion(false)
                } else if response.message == ResponseMessages.cardPinIncorrect.rawValue {
                    showErrorDialog(error: ResponseMessages.cardPinIncorrect.errorMessage())
                    completion(false)
                } else {
                    showErrorDialog(error: "Unknown error")
                    completion(false)
                }
            case .failure:
                showNetworkErrorDialog()
                completion(false)
            }
        })
    }
    
    func updateCardholderInfo(firstName: String? = nil, lastName: String? = nil, pronoun: String? = nil, gender: String? = nil, birthday: Birthday? = nil, contact: Contact? = nil, address: Address? = nil, avatar: PVPhoto? = nil, interests: [BusinessType]? = nil, callBack: @escaping(Result<Cardholder, Error>) -> Void) {
        guard let apiKey = api.apiKey else { return }
        
        let params = UpdateCardholderInfoParams(apiKey: apiKey, firstName: firstName, lastName: lastName, pronoun: pronoun, gender: gender, birthday: birthday, contact: contact, address: address, avatar: avatar, interests: interests)
        api.updateCardholderInfo(params: params) { result in
            switch result {
            case .success(let response):
                if response.success, let cardholder = response.data {
                    self.user?.cardholder = cardholder
                    callBack(.success(cardholder))
                } else if response.message == ResponseMessages.cardholderNotFound.rawValue {
                    showErrorDialog(error: ResponseMessages.cardholderNotFound.errorMessage())
                    callBack(.failure(ResponseError.cardholderNotFound))
                } else {
                    showErrorDialog(error: "Unknown error")
                    callBack(.failure(ResponseError.unknownError))
                }
            case .failure(let error):
                showNetworkErrorDialog()
                callBack(.failure(error))
            }
        }
    }
    
    func updateMerchantInfo(name: String?, field: BusinessType?, logo: PVPhoto? , photos: [PVPhoto]?, contact: Contact?, address: Address?, cards: [String]?, callBack: @escaping(Result<Merchant, Error>) -> Void) {
        guard let apiKey = api.apiKey else { return }
        
        let params = UpdateMerchantInfoParams(apiKey: apiKey, name: name, field: field, logo: logo, photos: photos, contact: contact, address: address, cards: cards)
        api.updateMerchantInfo(params: params) { result in
            switch result {
            case .success(let response):
                if response.success, let merchant = response.data {
                    self.user?.merchant = merchant
                    callBack(.success(merchant))
                } else if response.message == ResponseMessages.merchantNotFound.rawValue {
                    showErrorDialog(error: ResponseMessages.merchantNotFound.errorMessage())
                    callBack(.failure(ResponseError.merchantNotFound))
                } else {
                    showErrorDialog(error: "Unknown error")
                    callBack(.failure(ResponseError.unknownError))
                }
            case .failure(let error):
                showNetworkErrorDialog()
                callBack(.failure(error))
            }
        }
    }
    
    func proceedPastLogin() {
        guard let user = user else {
            return
        }

        if !user.isProfileComplete() {
            goToSetupProfile()
        } else {
            goToMain()
        }
    }
    
    private func goToSetupProfile() {
        StoryboardManager.load(storyboard: "SetupProfile")
    }
    
    private func goToMain() {
        StoryboardManager.load(storyboard: "Main")
    }
    
    func fetchUser(completion: @escaping (Bool) -> Void) {
        guard let apiKey = api.apiKey else { return }
        
        api.loginByAPIKey(loginKey: apiKey) { result in
            switch result {
            case .success(let response):
                if response.success, let user = response.data {
                    self.user = user
                    completion(true)
                } else {
                    completion(false)
                }
            case .failure:
                completion(false)
            }
        }
    }
    
    func logout() {
        api.logout { [weak self] _ in
            AppSettingsManager.shared.resetSettings()
            self?.user = nil
            self?.api.apiKey = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
            StoryboardManager.load(storyboard: "Login", animated: true, completion: nil)
        }
    }
    
    func clearSavedInformation() {
        api.logout { [weak self] _ in
            AppSettingsManager.shared.resetSettings()
            self?.user = nil
            self?.api.apiKey = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
        }
    }
    
    func saveLoginInfo() {
        if let apiKey = user?.user?.apiKey {
            try? myValet.setString(apiKey, forKey: "apiKey")
        } else {
            try? myValet.removeObject(forKey: "apiKey")
        }
    }
    
    func uploadPhoto(photo: UIImage, completion: @escaping (PVPhoto?) -> Void) {
        var userId: ObjectId! = user?.user?.identifier
        // demo code
        if userId == nil {
            userId = try! ObjectId(string: "62d2fec69f467f7f9e50c8e9")
        }
        
        let filename = String.randomString(length: 5)
        let thumbnailFileName = "\(filename)-thumb.jpg"
        let fullsizeFileName = "\(filename)-full.jpg"
        
        guard let thumbnail = Toucan(image: photo).resize(CGSize(width: 360, height: 360), fitMode: Toucan.Resize.FitMode.clip).image,
              let fullSize = Toucan(image: photo).resize(CGSize(width: 720, height: 720), fitMode: Toucan.Resize.FitMode.clip).image,
              let thumbnailData = thumbnail.jpeg,
              let fullSizeData = fullSize.jpeg,
              let thumbnailDataUrl = UIImage.saveImageToDocumentDirectory(filename: thumbnailFileName, jpegData: thumbnailData),
              let fullSizeDataUrl = UIImage.saveImageToDocumentDirectory(filename: fullsizeFileName, jpegData: fullSizeData)
        else { return }
        
        let finalThumbnailName = "\(userId.stringValue)/\(thumbnailFileName)"
        let finalFullName = "\(userId.stringValue)/\(fullsizeFileName)"
        let finalThumbnailURL = "\(api.s3RootURL)\(finalThumbnailName)"
        let finalFullURL = "\(api.s3RootURL)\(finalFullName)"
        
        var isSuccess: Bool = true
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.uploadS3file(fileUrl: thumbnailDataUrl,
                                  fileName: finalThumbnailName,
                                  progress: nil,
                                  completionHandler: { task, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            self.api.uploadS3file(fileUrl: fullSizeDataUrl,
                                  fileName: finalFullName,
                                  progress: nil,
                                  completionHandler: { task, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            })
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                if isSuccess {
                    completion(PVPhoto(thumbnailUrl: finalThumbnailURL, fullUrl: finalFullURL))
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    func deletePhoto(photo: PVPhoto, completion: @escaping (Bool) -> Void) {
        var isSuccess: Bool = true
        let queue = DispatchQueue.global(qos: .default)
        queue.async { [weak self] in
            guard let self = self else { return }
            
            let semaphore = DispatchSemaphore(value: 0)
            
            self.api.deleteS3file(fileURL: photo.thumbnailUrl, progress: nil) { response, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            guard isSuccess else {
                DispatchQueue.main.async {
                    completion(false)
                }
                return
            }
            
            self.api.deleteS3file(fileURL: photo.fullUrl, progress: nil) { response, error in
                if error != nil {
                    isSuccess = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            
            DispatchQueue.main.async {
                completion(isSuccess)
            }
        }
    }
}
