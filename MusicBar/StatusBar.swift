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
    
    override init() {
        super.init()
        Timer.scheduledTimer(timeInterval: 0.30, target: self, selector: #selector(setMedia), userInfo: nil, repeats: true)
        setupMenu()
    }
    
    @objc private func setMedia() {
        
        var songTitle: String?
        var songArtist: String?
        var image: NSImage?
        
        if let getNowPlaying = nowPlaying {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                let title = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String
                let artist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String
                let imageData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data
                if let songT = title {
                    songTitle = songT
                }
                if let songA = artist {
                    songArtist = songA
                }
                if let imageData = imageData {
                    image = NSImage(data: imageData)
                }
            })
        }
        
        func checkAvailable() -> NSImage? {
            if #available(macOS 11.0, *) {
                return NSImage(systemSymbolName: "rays", accessibilityDescription: "rays")
            } else {
                let image = NSImage(named: NSImage.Name("rays"))
                return image?.resizedCopy(w: 15, h: 15)
            }
        }
        
        if let button = statusItem.button {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let resized = (image != nil) ? image?.resizedCopy(w: 19, h: 19) : checkAvailable()
                let songTitleCheck = self.getSongTitle(songTitle)
                let dashCheck = (songTitle != nil && songArtist != nil) ? " - " : ""
                let songArtistCheck = self.getArtist(songArtist)
                
                button.title = " " + songTitleCheck + dashCheck + songArtistCheck
                button.image = resized
            }
        }
    }
    
    func getSongTitle(_ songTitle: String?) -> String {
        var songT = songTitle
        let cutPhrase = ["(feat.", "Feat.", "(produced by", "(with"]
        songT?.cut(separator: cutPhrase)
        return songT ?? "Music Not Playing"
    }
    
    func getArtist(_ songArtist: String?) -> String {
        var artistCut = songArtist
        let cutPhrase = [",", "&", "×"]
        artistCut?.cut(separator: cutPhrase)
        return artistCut ?? ""
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        menu.addItem(autoLaunchMenu())
        menu.addItem(NSMenuItem(title: "\(space)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func checkAction() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        setupMenu()
    }
    
    func autoLaunchMenu() -> NSMenuItem {
        let enabled = LaunchAtLogin.isEnabled ? "􀆅 " : space
        let menuItem =  NSMenuItem(title: "\(enabled)Launch At Login", action: #selector(checkAction), keyEquivalent: "")
        menuItem.target = self
        return menuItem
    }
    
//    func openSettings() -> NSMenuItem {
//        let menuItem = NSMenuItem(title: "\(space)Settings", action: #selector(showSettings), keyEquivalent: ",")
//        menuItem.target = self
//        return menuItem
//    }
    
}
