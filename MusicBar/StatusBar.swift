//
//  StatusBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import AppKit
import LaunchAtLogin
import SwiftUI

class StatusBar {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let space = "     "
    var nowPlaying = GetNowPlaying()
    
    private var firstLaunchInitiated = false
    private var lastTitle = ""
    private var lastArtist = ""
    private var lastImage = NSImage()
    
    var timer: Timer?
    
    init() {
        let thread = Thread {
            let customRunLoop = RunLoop.current
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), ThreadRunner.customObserver, CFRunLoopMode.commonModes)
            
            let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { (timer) in
                self.setMedia()
            }
            customRunLoop.add(timer, forMode: .default)
            
            customRunLoop.run()
            
        }
        
        thread.start()
        
        setupMenu()
        statusItem.button?.image = checkAvailable()
    }
    
    func startTimer(interval: Double = 0.75) {
        let thread = Thread {
            let customRunLoop = RunLoop.current
            
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), ThreadRunner.customObserver, CFRunLoopMode.commonModes)
            
            let timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { (timer) in
                self.setMedia()
            }
            customRunLoop.add(timer, forMode: .default)
            
            customRunLoop.run()
            
        }
        
        thread.start()
    }
    
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
            if getLimitText() || title.count < 32 {
                return trimmedTitle
            } else {
                return trimmedTitle.truncate(32)
            }
        } else if !trimmedTitle.isEmpty {
            if getLimitText() || (!trimmedArtist.isEmpty && combinedCount < 32) {
                return "\(trimmedTitle) - \(trimmedArtist)"
            } else if getLimitText() || title.count < 32 {
                return trimmedTitle
            } else {
                return trimmedTitle.truncate(32)
            }
        } else if !trimmedArtist.isEmpty {
            if getLimitText() || artist.count < 32 {
                return "Song by \(trimmedArtist)"
            } else {
                return "Song by \(trimmedArtist.truncate(32)))"
            }
        } else {
            return nil
        }
    }
    
    private func setMedia() {
        updateNowPlaying()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            guard let songTitle = self.nowPlaying.mediaInfo.songTitle else {
                self.handleNoSongTitle()
                return
            }
            self.updateStatusItemIfNeeded(songTitle: songTitle, artist: self.nowPlaying.mediaInfo.songArtist, artwork: self.nowPlaying.mediaInfo.albumArtwork)
        }
    }
    
    private func updateNowPlaying() {
        nowPlaying.fetchNowPlaying()
    }
    
    private func handleNoSongTitle() {
        statusItem.button?.image = checkAvailable()
        if firstLaunchInitiated {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {}
        } else {
            firstLaunchInitiated = true
        }
    }
    
    private func updateStatusItemIfNeeded(songTitle: String, artist: String?, artwork: NSImage?) {
        guard songTitle != lastTitle || artist != lastArtist || artwork != lastImage else { return }
        
        statusItem.length = NSStatusItem.variableLength
        if let button = statusItem.button {
            let resizedImage = artwork?.size.width != 0 ? artwork?.scaledCopy(sizeOfLargerSide: 19) : checkAvailable()
            let songTitleCheck = getSongTitle(songTitle)
            let songArtistCheck = getArtist(artist)
            
            let check = getCheck(songTitleCheck, songArtistCheck)
            
            button.image = resizedImage
            configureButtonTitle(button: button, check: check)
        }
    }
    
    private func configureButtonTitle(button: NSStatusBarButton, check: String?) {
        if let checkValue = check {
            let titleCombined = " " + checkValue
            
            if #available(macOS 11.0, *) {
                button.title = titleCombined
            } else {
                let attributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
                let attributedText = NSAttributedString(string: titleCombined, attributes: attributes)
                button.attributedTitle = attributedText
            }
            button.imagePosition = .imageLeft
        } else {
            button.imagePosition = .imageOnly
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
        menu._setHasPadding(false, onEdge: 1)
        menu._setHasPadding(false, onEdge: 3)

        
        if #available(macOS 11.0, *) {
            
            let menuView = NSMenuItem()
            let swiftUIView = NSHostingView(rootView: MenuView(info: nowPlaying))
            swiftUIView.frame = NSRect(x: 0, y: 0, width: 300, height: 500)
            
            menuView.view = swiftUIView
            
            menu.addItem(menuView)
        } else {
            menu.addItem(autoLaunchMenu())
            menu.addItem(showOnlySongTitle())
            menu.addItem(showLimitText())
            menu.addItem(NSMenuItem(title: "\(space)Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        }
        
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
