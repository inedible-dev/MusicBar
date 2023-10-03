//
//  StatusBar.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import AppKit
import SwiftUI
import MusicKit

class StatusBar {
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    let nowPlaying = MediaRemote()
    let localStorage = LocalStorage()
    
    private var firstLaunchInitiated = false
    var timer: Timer?
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.setMedia()
        }
        self.setupMenu()
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: Notification.Name("MediaUpdated"), object: nil)
    }
    
    // MARK: - Update View
    
    @objc private func updateView() {
        self.setMedia()
    }
    
    // MARK: - Get Status Bar Image
    
    func statusBarImage() -> NSImage? {
        if #available(macOS 12.0, *) {
            return NSImage(systemSymbolName: "music.note", accessibilityDescription: "loading")
        } else {
            let image = NSImage(named: NSImage.Name("music.note"))
            return image?.scaledCopy(sizeOfLargerSide: 15)
        }
    }
    
    // MARK: - Get Status Bar Text
    
    let maxLetters = 40
    
    func statusBarText(_ title: String, _ artist: String) -> String? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)
        let combinedCount = title.count + artist.count
        
        if localStorage.getSongTitleOnlyKey() {
            return handleSongTitleOnlyKey(trimmedTitle: trimmedTitle)
        }
        if !trimmedTitle.isEmpty {
            return handleNonEmptyTitle(trimmedTitle: trimmedTitle, trimmedArtist: trimmedArtist, combinedCount: combinedCount)
        }
        if !trimmedArtist.isEmpty {
            return handleNonEmptyArtist(trimmedArtist: trimmedArtist)
        }
        return nil
    }
    
    private func handleSongTitleOnlyKey(trimmedTitle: String) -> String {
        return localStorage.getLimitText() || trimmedTitle.count < maxLetters
        ? trimmedTitle
        : trimmedTitle.truncate(maxLetters)
    }
    
    private func handleNonEmptyTitle(trimmedTitle: String, trimmedArtist: String, combinedCount: Int) -> String {
        if localStorage.getLimitText() || (!trimmedArtist.isEmpty && combinedCount < maxLetters) {
            return "\(trimmedTitle) - \(trimmedArtist)"
        }
        if localStorage.getLimitText() || trimmedTitle.count < maxLetters {
            return trimmedTitle
        }
        return trimmedTitle.truncate(maxLetters)
    }
    
    private func handleNonEmptyArtist(trimmedArtist: String) -> String {
        return localStorage.getLimitText() || trimmedArtist.count < maxLetters
        ? "Song by \(trimmedArtist)"
        : "Song by \(trimmedArtist.truncate(maxLetters))"
    }
    
    // MARK: Cut Title / Artist
    
    private func cutSongTitle(_ songTitle: String?) -> String {
        var songT = songTitle
        let cutPhrase = ["(feat.", "Feat.", "(produced by", "(with", "(FEAT.", "FEAT."]
        songT?.cutFeat(separator: cutPhrase)
        return songT ?? "Music Not Playing"
    }
    
    private func cutArtist(_ songArtist: String?) -> String {
        var artistCut = songArtist
        let cutPhrase = [",", "&", "×"]
        
        artistCut?.cutFeat(separator: cutPhrase)
        return artistCut ?? ""
    }
    
    // MARK: - Update Now Playing
    
    func setMedia() {
        guard let songTitle = self.nowPlaying.mediaInfo.songTitle else {
            self.handleNoSongTitle()
            return
        }
        self.updateStatusItemIfNeeded(songTitle: songTitle, artist: self.nowPlaying.mediaInfo.songArtist, artwork: self.nowPlaying.mediaInfo.albumArtwork)
    }
    
    private func handleNoSongTitle() {
        if let button = statusItem.button {
            button.image = statusBarImage()
            button.title = ""
        }
        firstLaunchInitiated = true
    }
    
    private func updateStatusItemIfNeeded(songTitle: String, artist: String?, artwork: NSImage?) {
        statusItem.length = NSStatusItem.variableLength
        
        if let button = statusItem.button {
            var resizedImage: NSImage?
            
            if let artwork = artwork, artwork.size.width != 0 {
                resizedImage = artwork.scaledCopy(sizeOfLargerSide: 19)
            } else {
                resizedImage = statusBarImage()
            }
            
            let songTitleCheck = cutSongTitle(songTitle)
            let songArtistCheck = cutArtist(artist)
            
            let check = statusBarText(songTitleCheck, songArtistCheck)
            
            configureButtonTitle(button: button, check: check)
            
            button.image = resizedImage
        }
    }
    
    private func configureButtonTitle(button: NSStatusBarButton, check: String?) {
        if let check = check {
            if #available(macOS 11.0, *) {
                button.title = check
            } else {
                let attributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
                let attributedText = NSAttributedString(string: check, attributes: attributes)
                button.attributedTitle = attributedText
            }
            
            button.imagePosition = .imageLeft
        } else {
            button.imagePosition = .imageOnly
        }
    }
    
    // MARK: - Setup Menu
    
    func setupMenu() {
        
        let menu = NSMenu()
        
        if #available(macOS 12.0, *) {
            menu._setHasPadding(false, onEdge: 1)
            menu._setHasPadding(false, onEdge: 3)
            
            let menuView = NSMenuItem()
            let swiftUIView = NSHostingView(rootView: MenuView(info: nowPlaying))
            
            swiftUIView.setFrameSize(NSSize(width: 300, height: 550))
            
            menuView.view = swiftUIView
            
            menu.addItem(menuView)
        } else {
            let oldMenu = OldStatusBarSupport()
            
            menu.addItem(oldMenu.autoLaunchMenu())
            menu.addItem(oldMenu.onlySongTitleMenu())
            menu.addItem(oldMenu.limitTextMenu())
            menu.addItem(oldMenu.quitMenu())
        }
        
        statusItem.menu = menu
    }
}
