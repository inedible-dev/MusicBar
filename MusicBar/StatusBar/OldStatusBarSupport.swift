//
//  OldStatusBarSupport.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 6/6/23.
//

import LaunchAtLogin

class OldStatusBarSupport {
    
    private let space = "     "
    
    let statusBar = StatusBar()
    let localStorage = LocalStorage()
    
    @objc func toggleLaunchAtLogin() {
        SettingsData().toggleLaunchAtLogin()
        statusBar.setupMenu()
    }
    
    func checkCheckMark(_ label: String, arg: Bool) -> NSMutableAttributedString {
        if !arg { return NSMutableAttributedString(string: space + label) }
        
        if #available(macOS 11.0, *) {
            let imageAttachment = NSTextAttachment()
            imageAttachment.image = NSImage(systemSymbolName: "checkmark", accessibilityDescription: "Checkmark")
            
            let fullString = NSMutableAttributedString(attachment: imageAttachment)
            fullString.append(NSAttributedString(attachment: imageAttachment))
            fullString.append(NSAttributedString(string: " " + label))
            return fullString
        } else {
            return NSMutableAttributedString(string: "√  " + label)
        }
    }
    
    @objc func showOnlySongTitleToggle() {
        UserDefaults.standard.set(!localStorage.getSongTitleOnlyKey(), forKey: "songTitleOnly")
        
        statusBar.setupMenu()
    }
    
    @objc func limitTextToggle() {
        UserDefaults.standard.set(!localStorage.getLimitText(), forKey: "limitText")
        
        statusBar.setupMenu()
    }
    
    func autoLaunchMenu() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Launch At Login", arg: LaunchAtLogin.isEnabled)
        menuItem.action = #selector(toggleLaunchAtLogin)
        
        menuItem.target = self
        return menuItem
    }
    
    func onlySongTitleMenu() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Song Title Only", arg: localStorage.getSongTitleOnlyKey())
        menuItem.action = #selector(showOnlySongTitleToggle)
        
        menuItem.target = self
        
        return menuItem
    }
    
    func limitTextMenu() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Let Text Overflow", arg: localStorage.getLimitText())
        menuItem.action = #selector(limitTextToggle)
        
        menuItem.target = self
        
        return menuItem
    }
    
    func quitMenu() -> NSMenuItem {
        return NSMenuItem(title: "\(space)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
    }
    
}
