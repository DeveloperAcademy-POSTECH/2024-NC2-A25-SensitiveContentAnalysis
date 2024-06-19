//
//  StorageManager.swift
//  Ungteoring
//
//  Created by Juhyeon Byun on 6/19/24.
//

import Foundation

public class StorageManager {
    
    static func isFirstTime() -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: "isFirstTime") == nil {
            defaults.set("No", forKey:"isFirstTime")
            return true
        } else {
            return false
        }
    }
    
}
