//
//  DataManager.swift
//  IntervalRunning
//
//  Created by Dmitry Gorbunow on 6/1/23.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    
    let defaults = UserDefaults.standard
    
    func get(key: String) -> Any {
        return defaults.object(forKey: key) as Any
    }
    
    func set(key: String, value: Any) {
        defaults.set(value, forKey: key)
    }
}
