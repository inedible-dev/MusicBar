//
//  CustomMenu.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 6/12/23.
//

class MenuDelegate: NSObject, NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        StatusBar.menuOpenActions()
    }
    
    func menuDidClose(_ menu: NSMenu) {
        StatusBar.menuCloseActions()
    }
}
