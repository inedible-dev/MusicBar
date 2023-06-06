//
//  LocalStorage.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 6/6/23.
//

class LocalStorage {
    func getSongTitleOnlyKey() -> Bool {
        return UserDefaults.standard.bool(forKey: "songTitleOnly")
    }
    
    func getLimitText() -> Bool {
        return UserDefaults.standard.bool(forKey: "limitText")
    }
}
