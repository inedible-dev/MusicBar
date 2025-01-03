//
//  StatusBarController.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Cocoa
import Foundation
import AppKit
import MusicKit
@preconcurrency import PrivateMediaRemote
import Combine

struct MediaRemoteInfo: Equatable {
    var songTitle: String?
    var songArtist: String?
    var albumArtwork: Data?
    var isPlaying: Bool?
    var elapsedTime: Double?
    var elapsedTimeState: ElapsedTimeState?
    var timestamp: Date?
    var duration: TimeInterval?
    var isLive: Bool?
    var isMusicApp: Bool?
    var clientName: String?
    var clientIcon: NSImage?
}

enum ElapsedTimeState {
    case useElapsedTime, useIntervalAndElapsedTime
}

@MainActor
final class MediaRemote: ObservableObject {
    
    @Published var mediaInfo = MediaRemoteInfo()
    
    var firstLaunchInitiated = false
    
    private var infoChangedCancellable: AnyCancellable?
    
    init() {
        if !firstLaunchInitiated {
            fetchNowPlaying()
            firstLaunchInitiated = true
        }
        
        setupNowPlayingNotifications()
    }
    
    private func setupNowPlayingNotifications() {
        infoChangedCancellable = NotificationCenter.default
            .publisher(for: NSNotification.Name.mrMediaRemoteNowPlayingInfoDidChange)
            .throttle(for: .seconds(1), scheduler: DispatchQueue.main, latest: true)
            .sink { [weak self] _ in
                self?.fetchNowPlaying()
            }
        
        MRMediaRemoteRegisterForNowPlayingNotifications(.main)
    }
    
    private func fetchNowPlaying() {
        fetchNowPlayingInfo()
        fetchNowPlayingClient()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            StatusBar.setMedia()
        }
    }
    
    private func fetchNowPlayingInfo() {
        MRMediaRemoteGetNowPlayingInfo(.main) { [weak self] info in
            guard let self = self, let info = info as? [String: Any] else { return }
            
            self.formatNowPlaying(information: info)
        }
    }
    
    private func fetchNowPlayingClient() {
        MRMediaRemoteGetNowPlayingClient(.main) { [weak self] client in
            guard let self = self else { return }
            
                self.mediaInfo.clientName = client?.displayName
                if let bundleIdentifier = client?.bundleIdentifier {
                    self.mediaInfo.clientIcon = self.getAppIcon(bundleIdentifier: bundleIdentifier)
                }
        }
    }
    
    private func getAppIcon(bundleIdentifier: String) -> NSImage? {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            let appIcon = NSWorkspace.shared.icon(forFile: appURL.path)
            return appIcon
        }
        return nil
    }
    
    // MARK: - Analyze Now Playing Algorithm
    
    @objc func formatNowPlaying(information: [String : Any]) {
        
        print(information)
        
        let pastTitle = self.mediaInfo.songTitle
        let pastArtist = self.mediaInfo.songArtist
        
        if information["kMRMediaRemoteNowPlayingInfoTitle"] as? String == nil &&
            information["kMRMediaRemoteNowPlayingInfoArtist"] as? String == nil {
            self.mediaInfo = MediaRemoteInfo()
        } else {
            if let timestamp = information["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date {
                
                self.mediaInfo.timestamp = timestamp
                
                let isMusicApp = information["kMRMediaRemoteNowPlayingIsMusicApp"] as? Bool
                
                self.mediaInfo.isMusicApp = isMusicApp
                
                if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double,
                   let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
                    
                    self.mediaInfo.duration = duration
                    
                    let interval = Date().timeIntervalSince(timestamp) + elapsedTime
                    
                    if interval.truncatingRemainder(dividingBy: 3600) < duration.truncatingRemainder(dividingBy: 3600) {
                        if self.mediaInfo.isPlaying == true {
                            self.mediaInfo.isLive = false
                        }
                        //                        self.mediaInfo.elapsedTime = interval
                        self.mediaInfo.elapsedTime = elapsedTime
                        self.mediaInfo.elapsedTimeState = .useIntervalAndElapsedTime
                    } else {
                        if isMusicApp != true && self.mediaInfo.isPlaying == true  {
                            self.mediaInfo.isLive = true
                        }
                    }
                } else {
                    self.mediaInfo.isLive = false
                }
                
                let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double
                
                if playbackRate == 0 || playbackRate == nil {
                    self.mediaInfo.isPlaying = false
                    if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
                        self.mediaInfo.elapsedTime = elapsedTime
                        self.mediaInfo.elapsedTimeState = .useElapsedTime
                    }
                } else {
                    self.mediaInfo.isPlaying = true
                }
                
                if let infoTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                    self.mediaInfo.songTitle = infoTitle
                }
                
                if let infoArtist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                    self.mediaInfo.songArtist = infoArtist
                }
                
                if let infoImageData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    self.mediaInfo.albumArtwork = infoImageData
                    
                    let image = NSImage(data: infoImageData)
                    if let image = image, image.size.width < 250 {
                        
                    }
                } else {
                    if let title = self.mediaInfo.songTitle,
                       let artist = self.mediaInfo.songArtist,
                       pastTitle != title || pastArtist != artist {
                        self.mediaInfo.albumArtwork = nil
                    }
                }
            }
        }
    }
    
    // MARK: - Send MediaRemote Commands
    
    func controlMedia(command: MRMediaRemoteCommand) {
        MRMediaRemoteSendCommand(command, nil)
    }
}
