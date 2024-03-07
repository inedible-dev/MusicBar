//
//  LocalStorage.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 6/6/23.
//

struct LocalStorage {
    func getSongTitleOnlyKey() -> Bool {
        return UserDefaults.standard.bool(forKey: "songTitleOnly")
    }
    
    func getLimitText() -> Bool {
        return UserDefaults.standard.bool(forKey: "limitText")
    }
    
    func getMaxStatusBarCharacters() -> Int {
        return UserDefaults.standard.integer(forKey: "maxStatusBarCharacters")
    }
    
    func setMaxStatusBarCharacters(_ max: Int) {
        UserDefaults.standard.set(max, forKey: "maxStatusBarCharacters")
    }
}
