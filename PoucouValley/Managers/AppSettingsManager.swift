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
        return defaults.object(forKey: SearchHistoryKey) as? [String] ?? []
    }
    
    func setSearchHistory(searchHistory: [String]) {
        settings[SearchHistoryKey] = searchHistory
        saveSettings()
    }
   
    func resetSettings() {
        settings = [:]
        defaults.set(settings, forKey: AppSettingsKey)
        defaults.synchronize()
    }
}
