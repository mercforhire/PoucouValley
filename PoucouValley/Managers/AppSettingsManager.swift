//
//  AppSettingsManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation

enum Environments: String {
    case production
    case development
    
    func appID() -> String {
        switch self {
        case .production:
            return "clientvalley-dev-ouotd"
        case .development:
            return "clientvalley-dev-ouotd"
        }
    }
}

class AppSettingsManager {
    static let shared = AppSettingsManager()
    
    private let AppSettingsKey : String = "AppSettings"
    private let EnvironmentKey: String = "Environment"
    private let GetStartedViewedKey: String = "GetStartedViewed"
    private let LastUsedEmailKey: String = "LastUsedEmail"
    
    private let defaults = UserDefaults.standard
    private var settings: [String: Any] = [:]
    
    init() {
        loadSettingsFromPersistence()
    }
    
    private func loadSettingsFromPersistence() {
        //load previous Settings
        settings = defaults.dictionary(forKey: AppSettingsKey) ?? [:]
    }
    
    private func saveSettings() {
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
    
    func getEnvironment() -> Environments {
        return Environments(rawValue: (settings[EnvironmentKey] as? String) ?? "") ?? .production
    }
    
    func setEnvironment(environments: Environments) {
        settings[EnvironmentKey] = environments.rawValue
        saveSettings()
    }
    
    func isGetStartedViewed() -> Bool {
        return settings[GetStartedViewedKey] != nil
    }
    
    func setGetStartedViewed(viewed: Bool) {
        if viewed {
            settings[GetStartedViewedKey] = true
        } else {
            settings[GetStartedViewedKey] = nil
        }
        saveSettings()
    }
    
    func getLastUsedEmail() -> String? {
        return settings[LastUsedEmailKey] as? String
    }
    
    func setLastUsedEmail(email: String?) {
        settings[LastUsedEmailKey] = email
        saveSettings()
    }
   
    func resetSettings() {
        // don't forget the environment settings
        let current = getEnvironment()
        settings = [:]
        settings[EnvironmentKey] = current.rawValue
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
