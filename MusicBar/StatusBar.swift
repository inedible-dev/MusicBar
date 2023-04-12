//
//  StatusBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import AppKit
import LaunchAtLogin

class StatusBar: NSObject {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    var nowPlaying = GetNowPlaying().getNowPlaying()
    private let space = "     "
    
    private var firstLaunchInitiated = false
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
                return image?.scaledCopy(sizeOfLargerSide: 15)
            }
        }
        
        func getCheck(_ title: String, _ artist: String) -> String? {
            let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
            let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)
            
            let combinedCount = title.count + artist.count
            
            if getSongTitleOnlyKey() {
                if getLimitText() || title.count <= 32 {
                    return trimmedTitle
                } else {
                    return String(trimmedTitle.prefix(32)) + "..."
                }
            } else if !trimmedTitle.isEmpty {
                if getLimitText() || (!trimmedArtist.isEmpty && combinedCount < 32) {
                    return "\(trimmedTitle) - \(trimmedArtist)"
                } else if getLimitText() || title.count <= 32 {
                    return trimmedTitle
                } else {
                    return String(trimmedTitle.prefix(32)) + "..."
                }
            } else if !trimmedArtist.isEmpty {
                if getLimitText() || artist.count <= 32 {
                    return "Song by \(trimmedArtist)"
                } else {
                    return "Song by \(String(trimmedArtist.prefix(32)) + "...")"
                }
            } else {
                return nil
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
                        let resized = (image != nil) ? image?.scaledCopy(sizeOfLargerSide: 19) : checkAvailable()
                        let songTitleCheck = self.getSongTitle(songTitle)
                        let songArtistCheck = self.getArtist(songArtist)
                        
                        let check = getCheck(songTitleCheck, songArtistCheck)
                        
                        button.image = resized
                        
                        if (check != nil) {
                            let titleCombined = " " + (check ?? "")
                            
                            if #available(macOS 11.0, *) {
                                button.title = titleCombined
                            }
                            else {
                                let attributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
                                let attributedText = NSAttributedString(string: titleCombined, attributes: attributes)
                                button.attributedTitle = attributedText
                            }
                            button.imagePosition = .imageLeft
                        } else {
                            button.imagePosition = .imageOnly
                        }
                        
                    }
                }
            } else {
                self.statusItem.length = 18
                if let button = self.statusItem.button {
                    button.image = checkAvailable()
                }
                if(self.firstLaunchInitiated) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {}
                } else {
                    self.firstLaunchInitiated = true
                }
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
        menu.addItem(showLimitText())
        menu.addItem(NSMenuItem(title: "\(space)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    func checkCheckMark(_ label: String, arg: Bool) -> NSMutableAttributedString {
        if (arg) {
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
        } else {
            return NSMutableAttributedString(string: space + label)
        }
    }
    
    @objc func checkAction() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
        
        setupMenu() //resets symbol
    }
    
    func autoLaunchMenu() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Launch At Login", arg: LaunchAtLogin.isEnabled)
        menuItem.action = #selector(checkAction)
        
        menuItem.target = self
        return menuItem
    }
    
    func getSongTitleOnlyKey() -> Bool {
        return UserDefaults.standard.bool(forKey: "songTitleOnly")
    }
    
    @objc func showOnlySongTitleToggle() {
        UserDefaults.standard.set(!getSongTitleOnlyKey(), forKey: "songTitleOnly")
        
        setupMenu() //resets symbol
    }
    
    func showOnlySongTitle() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Song Title Only", arg: getSongTitleOnlyKey())
        menuItem.action = #selector(showOnlySongTitleToggle)
        
        menuItem.target = self
        
        return menuItem
    }
    
    func getLimitText() -> Bool {
        return UserDefaults.standard.bool(forKey: "limitText")
    }
    
    @objc func limitTextToggle() {
        UserDefaults.standard.set(!getLimitText(), forKey: "limitText")
        
        setupMenu() //resets symbol
    }
    
    func showLimitText() -> NSMenuItem {
        let menuItem =  NSMenuItem()
        menuItem.attributedTitle = checkCheckMark("Let Text Overflow", arg: getLimitText())
        menuItem.action = #selector(limitTextToggle)
        
        menuItem.target = self
        
        return menuItem
    }
}
