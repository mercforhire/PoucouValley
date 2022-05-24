//
//  UserManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-27.
//

import Foundation
import Valet
import Toucan

class UserManager {
    var user: UserDetails? {
        didSet {
            guard let user = user?.user else {
                api.apiKey = nil
                return
            }
            
            api.apiKey = user.apiKey
        }
    }
    
    static let shared = UserManager()
    
    private let myValet = Valet.valet(with: Identifier(nonEmpty: "CPLove")!, accessibility: .whenUnlocked)
    private var api: PoucouAPI {
        return PoucouAPI.shared
    }
    
    init() {
        if let apiKey = try? myValet.string(forKey: "apiKey") {
            api.service.accessToken = apiKey
        }
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
            case .failure(let error):
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
            case .failure(let error):
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
            case .failure(let error):
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
            case .failure(let error):
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
            case .failure(let error):
                showNetworkErrorDialog()
                completion(false)
            }
        }
    }
    
    func updateCardholderInfo(firstName: String?, lastName: String?, pronoun: String?, gender: String?, birthday: Birthday?, contact: Contact?, address: Address?, avatar: PVPhoto?, interests: [BusinessType]?, callBack: @escaping(Result<Cardholder, Error>) -> Void) {
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

        if user.isProfileComplete() {
            goToSetupProfile()
        } else {
            goToMain()
        }
    }
    
    func goToSetupProfile() {
        StoryboardManager.load(storyboard: "SetupProfile")
    }
    
    func goToMain() {
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
            case .failure(let error):
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
}
