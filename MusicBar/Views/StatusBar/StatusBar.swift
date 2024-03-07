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
    static let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    static let nowPlaying = MediaRemote()
    
    static private var firstLaunchInitiated = false
    var timer: Timer?
    
    var menuDelegate: MenuDelegate?
    
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            StatusBar.setMedia()
        }
        self.setupMenu()
    }
    
    // MARK: - Update View
    
    static func menuOpenActions() {
        if self.nowPlaying.mediaInfo.isPlaying != nil {
            statusItem.length = 100
        }
    }
    
    static func menuCloseActions() {
        statusItem.length = NSStatusItem.variableLength
    }
    
    // MARK: - Get Status Bar Image
    
    static func statusBarImage() -> NSImage? {
        if #available(macOS 12.0, *) {
            return NSImage(systemSymbolName: "music.note", accessibilityDescription: "loading")
        } else {
            let image = NSImage(named: NSImage.Name("music.note"))
            return image?.scaledCopy(sizeOfLargerSide: 15)
        }
    }
    
    // MARK: - Get Status Bar Text
    
    static func statusBarText(_ title: String, _ artist: String) -> String? {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        let trimmedArtist = artist.trimmingCharacters(in: .whitespaces)
        let combinedCount = title.count + artist.count
        
        if LocalStorage().getSongTitleOnlyKey() {
            return handleSongTitleOnlyKey(trimmedTitle)
        }
        if !trimmedTitle.isEmpty {
            return handleNonEmptyTitle(trimmedTitle, trimmedArtist, combinedCount)
        }
        if !trimmedArtist.isEmpty {
            return handleNonEmptyArtist(trimmedArtist)
        }
        return nil
    }
    
    private static func handleSongTitleOnlyKey(_ trimmedTitle: String) -> String {
        return LocalStorage().getLimitText() || trimmedTitle.count < LocalStorage().getMaxStatusBarCharacters()
        ? trimmedTitle
        : trimmedTitle.truncate(LocalStorage().getMaxStatusBarCharacters())
    }
    
    private static func handleNonEmptyTitle(_ trimmedTitle: String,_ trimmedArtist: String,_ combinedCount: Int) -> String {
        if LocalStorage().getLimitText() || (!trimmedArtist.isEmpty && combinedCount < LocalStorage().getMaxStatusBarCharacters()) {
            return "\(trimmedTitle) - \(trimmedArtist)"
        }
        if LocalStorage().getLimitText() || trimmedTitle.count < LocalStorage().getMaxStatusBarCharacters() {
            return trimmedTitle
        }
        return trimmedTitle.truncate(LocalStorage().getMaxStatusBarCharacters())
    }
    
    private static func handleNonEmptyArtist(_ trimmedArtist: String) -> String {
        return LocalStorage().getLimitText() || trimmedArtist.count < LocalStorage().getMaxStatusBarCharacters()
        ? "Song by \(trimmedArtist)"
        : "Song by \(trimmedArtist.truncate(LocalStorage().getMaxStatusBarCharacters()))"
    }
    
    // MARK: Cut Title / Artist
    
    private static func cutSongTitle(_ songTitle: String?) -> String {
        var songT = songTitle
        let cutPhrase = ["(feat.", "Feat.", "(produced by", "(with", "(FEAT.", "FEAT.", "(prod", "prod.", "(Original Soundtrack"]
        songT?.cutFeat(separator: cutPhrase)
        return songT ?? "Music Not Playing"
    }
    
    private static func cutArtist(_ songArtist: String?) -> String {
        var artistCut = songArtist
        let cutPhrase = [",", "&", "×", "-"]
        
        artistCut?.cutFeat(separator: cutPhrase)
        return artistCut ?? ""
    }
    
    // MARK: - Update Now Playing
    
    static func setMedia() {
        guard let songTitle = StatusBar.nowPlaying.mediaInfo.songTitle else {
            self.handleNoSongTitle()
            return
        }
        self.updateStatusItemIfNeeded(songTitle: songTitle, artist: StatusBar.nowPlaying.mediaInfo.songArtist, artwork: NSImage(data: StatusBar.nowPlaying.mediaInfo.albumArtwork ?? Data()))
    }
    
    private static func handleNoSongTitle() {
        if let button = StatusBar.statusItem.button {
            button.image = statusBarImage()
            button.title = ""
        }
        firstLaunchInitiated = true
    }
    
    private static func updateStatusItemIfNeeded(songTitle: String, artist: String?, artwork: NSImage?) {
        
        if let button = StatusBar.statusItem.button {
            var resizedImage: NSImage?
            
            if let artwork = artwork, artwork.size.width != 0 {
                resizedImage = artwork.scaledCopy(sizeOfLargerSide: 19)
            } else {
                resizedImage = StatusBar.statusBarImage()
            }
            
            let songTitleCheck = cutSongTitle(songTitle)
            let songArtistCheck = cutArtist(artist)
            
            let check = statusBarText(songTitleCheck, songArtistCheck)
            
            configureButtonTitle(button: button, check: check)
            
            button.image = resizedImage
            
            button.imagePosition = .imageLeft
        }
    }
    
    private static func configureButtonTitle(button: NSStatusBarButton, check: String?) {
        if let check = check {
            
            let addSpacing = " " + check
            
            if LocalStorage().getMaxStatusBarCharacters() > 0 {
                if #available(macOS 11.0, *) {
                    button.title = addSpacing
                    button.lineBreakMode = NSLineBreakMode.byTruncatingTail
                } else {
                    let attributes = [NSAttributedString.Key.foregroundColor: NSColor.white]
                    let attributedText = NSAttributedString(string: addSpacing, attributes: attributes)
                    button.attributedTitle = attributedText
                }
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
            let swiftUIView = NSHostingView(rootView: MenuView(info: StatusBar.nowPlaying))
            
            swiftUIView.setFrameSize(NSSize(width: 300, height: 550))
            
            menuView.view = swiftUIView
            
            menu.addItem(menuView)
            
            self.menuDelegate = MenuDelegate()
            
            menu.delegate = self.menuDelegate
        } else {
            let oldMenu = OldStatusBarSupport()
            
            menu.addItem(oldMenu.autoLaunchMenu())
            menu.addItem(oldMenu.onlySongTitleMenu())
            menu.addItem(oldMenu.limitTextMenu())
            menu.addItem(oldMenu.quitMenu())
        }
        
        StatusBar.statusItem.menu = menu
    }
}
