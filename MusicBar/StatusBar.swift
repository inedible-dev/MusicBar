//
//  StatusBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Foundation
import AppKit
import LaunchAtLogin

class StatusBar: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var nowPlaying = GetNowPlaying().getNowPlaying()
    private let space = "     "
    
    private var lastTitle = ""
    private var lastArtist = ""
    private var lastImage = NSImage()
    
    override init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(setMedia), userInfo: nil, repeats: true)
        setupMenu()
    }
    
    @objc private func setMedia() {
        
        var songTitle: String?
        var songArtist: String?
        var image: NSImage?
        
        func checkAvailable() -> NSImage? {
            if #available(macOS 11.0, *) {
                return NSImage(systemSymbolName: "music.note", accessibilityDescription: "loading")
            } else {
                let image = NSImage(named: NSImage.Name("music.note"))
                return image?.resizedCopy(w: 15, h: 15)
            }
        }
        
        func getCheck(_ t: String,_ a: String) -> String {
            let t = t.trimmingCharacters(in: .whitespaces)
            let a = a.trimmingCharacters(in: .whitespaces)
            
            if(getsongTitleOnlyKey()) {
                return t
            } else if (t != "") {
                if(a != "") {
                    return "\(t) - \(a)"
                } else {
                    return t
                }
            } else if(a != "") {
                return "Song by \(a)"
            } else {
                return ""
            }
        }
        
        if let getNowPlaying = nowPlaying {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                if let infoTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                    songTitle = infoTitle
                }
                if let infoArtist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                    songArtist = infoArtist
                }
                if let infoImageData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    image = NSImage(data: infoImageData)
                }
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if(songTitle != nil) {
                if(songTitle != self.lastTitle || songArtist != self.lastArtist || image != self.lastImage) {
                    self.statusItem.length = NSStatusItem.variableLength
                    if let button = self.statusItem.button {
                        let resized = (image != nil) ? image?.resizedCopy(w: 19, h: 19) : checkAvailable()
                        let songTitleCheck = self.getSongTitle(songTitle)
                        let songArtistCheck = self.getArtist(songArtist)
                        
                        
                        let titleCombined = " " + getCheck(songTitleCheck, songArtistCheck)
                        
                        if #available(macOS 11.0, *) {
                            button.title = titleCombined
                        }
                        else {
                            let attributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
                            let attributedText = NSAttributedString(string: titleCombined, attributes: attributes)
                            button.attributedTitle = attributedText
                        }
                        
                        button.image = resized
                        button.imagePosition = .imageLeft
                    }
                }
            } else {
                self.statusItem.length = 18
                if let button = self.statusItem.button {
                    button.image = checkAvailable()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {}
            }
        }
    }
    
    func getSongTitle(_ songTitle: String?) -> String {
        var songT = songTitle
        let cutPhrase = ["(feat.", "Feat.", "(produced by", "(with"]
        songT?.cutFeat(separator: cutPhrase)
        return songT ?? "Music Not Playing"
    }
    
    func getArtist(_ songArtist: String?) -> String {
        var artistCut = songArtist
        let cutPhrase = [",", "&", "×"]
        artistCut?.cutFeat(separator: cutPhrase)
        return artistCut ?? ""
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        menu.addItem(autoLaunchMenu())
        menu.addItem(showOnlySongTitle())
        menu.addItem(NSMenuItem(title: "\(space)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func getCheck() -> String {
        if #available(macOS 11.0, *) {
            return "􀆅 "
        } else {
            return "√  "
        }
    }
    
    @objc func checkAction() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        
        setupMenu() //resets symbol
    }
    
    func autoLaunchMenu() -> NSMenuItem {
        
        let enabled = LaunchAtLogin.isEnabled ? getCheck() : space
        let menuItem =  NSMenuItem(title: "\(enabled)Launch At Login", action: #selector(checkAction), keyEquivalent: "")
        menuItem.target = self
        return menuItem
    }
    
    func getsongTitleOnlyKey() -> Bool {
        return UserDefaults.standard.bool(forKey: "songTitleOnly")
    }
    
    @objc func showOnlySongTitleToggle() {
        UserDefaults.standard.set(!getsongTitleOnlyKey(), forKey: "songTitleOnly")
        
        setupMenu() //resets symbol
    }
    
    func showOnlySongTitle() -> NSMenuItem {
        let key = getsongTitleOnlyKey()
        let enabled = key ? getCheck() : space
        let menuItem =  NSMenuItem(title: "\(enabled)Song Title Only", action: #selector(showOnlySongTitleToggle), keyEquivalent: "")
        menuItem.target = self
        
        return menuItem
    }
}
