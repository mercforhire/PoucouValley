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
    
    func sendCode(email: String, login: Bool, completion: @escaping (Bool) -> Void) {
        
    }
    
    func login(email: String, code: String, completion: @escaping (Bool) -> Void) {
        
    }
    
    func register(email: String, code: String, userType: UserTypeMode, completion: @escaping (Bool) -> Void) {
        
    }
    
    func proceedPassLogin() {
        
    }
    
    func goToMain() {
        
    }
    
    func fetchUser(initialize: Bool, completion: @escaping (Bool) -> Void) {
        
    }
    
    func logout() {
        api.logout { [weak self] _ in
            AppSettingsManager.shared.resetSettings()
            self?.api.apiKey = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
            StoryboardManager.load(storyboard: "Login", animated: true, completion: nil)
        }
    }
    
    func clearSavedInformation() {
        api.logout { [weak self] _ in
            AppSettingsManager.shared.resetSettings()
            self?.api.apiKey = nil
            try? self?.myValet.removeAllObjects()
            self?.saveLoginInfo()
        }
    }
    
    func saveLoginInfo() {
        if let apiKey = api.apiKey {
            try? myValet.setString(apiKey, forKey: "apiKey")
        }
    }
}
