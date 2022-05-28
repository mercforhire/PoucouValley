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
    
    func hostUrl() -> String {
        switch self {
        case .production:
            return "https://api.unsplash.com/"
        case .development:
            return "https://api.unsplash.com/"
        }
    }
    
    func appID() -> String {
        switch self {
        case .production:
            return "clientvalley-dev-ouotd"
        case .development:
            return "clientvalley-dev-ouotd"
        }
    }
    
    func s3RootURL() -> String {
        switch self {
        case .production:
            return "https://poucouvalleydev.s3.amazonaws.com/"
        case .development:
            return "https://poucouvalleydev.s3.amazonaws.com/"
        }
        
    }
    
    func bucketName() -> String {
        switch self {
        case .production:
            return "poucouvalleydev"
        case .development:
            return "poucouvalleydev"
        }
        
    }
    
    func s3Key() -> String {
        switch self {
        case .production:
            return "AKIAWCR5T7PCETYGICA6"
        case .development:
            return "AKIAWCR5T7PCETYGICA6"
        }
    }
    
    func accessKey() -> String {
        switch self {
        case .production:
            return "J49sndroCnjCxuoRpjLlb/EiEKACIANqwuP7rT68"
        case .development:
            return "J49sndroCnjCxuoRpjLlb/EiEKACIANqwuP7rT68"
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
