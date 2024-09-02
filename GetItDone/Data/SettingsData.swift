//
//  SettingsData.swift
//  GetItDone
//
//  Created by Gerardo Gallegos on 9/1/24.
//

import Foundation

struct SettingsData {
    func getSetting(for option: String) -> String? {
        if let setting = UserDefaults.standard.string(forKey: option) {
            return setting
        } else {
            return nil
        }
    }
    
    func saveSetting(for option: String, with value: String) {
        UserDefaults.standard.setValue(value, forKey: option)
    }
}
