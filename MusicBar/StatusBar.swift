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
        
        if let button = statusItem.button {
            button.frame = CGRectMake(0.0, 0.5, button.frame.width, button.frame.height)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let resized = (image != nil) ? image?.resizedCopy(w: 19, h: 19) : NSImage(systemSymbolName: "rays", accessibilityDescription: "rays")
                let songTitleCheck = songTitle ?? "Music Not Playing"
                let dashCheck = (songTitle != nil && songArtist != nil) ? " - " : ""
                let songArtistCheck = songArtist ?? ""
                
                button.title = songTitleCheck + dashCheck + songArtistCheck
                button.image = resized
            }
        }
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        menu.addItem(autoLaunchMenu())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
    }
    
    @objc func checkAction() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        setupMenu()
    }
    
    func autoLaunchMenu() -> NSMenuItem {
        
        let menuItem = NSMenuItem(title: "Launch At Login", action: #selector(checkAction), keyEquivalent: "")
        menuItem.state = LaunchAtLogin.isEnabled ? .on : .off
        menuItem.target = self
        
        return menuItem
    }
    
}
