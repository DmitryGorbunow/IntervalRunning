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
    
    func get(key: String) -> Float {
        return defaults.float(forKey: key)
    }
    
    func set(key: String, value: Float) {
        defaults.set(value, forKey: key)
    }
}
