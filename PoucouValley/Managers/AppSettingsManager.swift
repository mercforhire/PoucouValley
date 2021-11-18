//
//  AppSettingsManager.swift
//  ClickMe
//
//  Created by Leon Chen on 2021-05-28.
//

import Foundation

class AppSettingsManager {
    static let shared = AppSettingsManager()
    
    private let AppSettingsKey : String = "AppSettings"
    private let SearchHistoryKey : String = "SearchHistory"
    private let SearchRecentsKey : String = "SearchRecents"
    
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
    
    func getSearchHistory() -> [String] {
        return settings[SearchHistoryKey] as? [String] ?? []
    }
    
    func setSearchHistory(searchHistory: [String]) {
        settings[SearchHistoryKey] = searchHistory
        saveSettings()
    }
    
    func getSearchRecents() -> [UnsplashSearchResult] {
        if let savedData = settings[SearchRecentsKey] as? Data {
            let decoder = JSONDecoder()
            if let savedSearchRecents = try? decoder.decode([UnsplashSearchResult].self, from: savedData) {
                return savedSearchRecents
            }
        }
        return []
    }
    
    func setSearchRecents(searchRecents: [UnsplashSearchResult]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(searchRecents) {
            settings[SearchRecentsKey] = encoded
            saveSettings()
        }
    }
   
    func resetSettings() {
        settings = [:]
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
