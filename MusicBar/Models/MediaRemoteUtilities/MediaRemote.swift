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
}

enum ElapsedTimeState {
    case useElapsedTime, useIntervalAndElapsedTime
}

class MediaRemote: ObservableObject {
    
    @Published var mediaInfo = MediaRemoteInfo()
    
    var firstLaunchInitiated = false
    
    private static let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
    
    let MRMediaRemoteRegisterForNowPlayingNotificationsPointer = CFBundleGetFunctionPointerForName(
        bundle, "MRMediaRemoteRegisterForNowPlayingNotifications" as CFString
    )
    typealias MRMediaRemoteRegisterForNowPlayingNotificationsFunction = @convention(c) (DispatchQueue) -> Void
    
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    typealias MRNowPlayingClientGetBundleIdentifierFunction = @convention(c) (AnyObject?) -> String
    
    func getNowPlaying() -> MRMediaRemoteGetNowPlayingInfoFunction? {
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(MediaRemote.bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return nil }
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get a Swift function for MRNowPlayingClientGetBundleIdentifier
        guard CFBundleGetFunctionPointerForName(MediaRemote.bundle, "MRNowPlayingClientGetBundleIdentifier" as CFString) != nil else { return nil }
        
        return MRMediaRemoteGetNowPlayingInfo
    }
    
    init() {
        let MRMediaRemoteRegisterForNowPlayingNotifications = unsafeBitCast(MRMediaRemoteRegisterForNowPlayingNotificationsPointer, to: MRMediaRemoteRegisterForNowPlayingNotificationsFunction.self)
        
        let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(
            MediaRemote.bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString)
        typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(
            MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self
        )
        
        if let getNowPlaying = self.getNowPlaying() {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                self.fetchNowPlaying(information: information)
            })
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "kMRMediaRemoteNowPlayingInfoDidChangeNotification"), object: nil, queue: nil) { (notification) in
            MRMediaRemoteGetNowPlayingInfo(DispatchQueue.main, { (information) in
                self.fetchNowPlaying(information: information)
                StatusBar.setMedia()
            })
        }
        MRMediaRemoteRegisterForNowPlayingNotifications(DispatchQueue.main);
    }
    
    // MARK: - Analyze Now Playing Algorithm
    
    @objc func fetchNowPlaying(information: [String : Any]) {
        
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
    
    typealias funcType = @convention(c) (Int, NSDictionary?) -> Void
    
    private func sendCommand(_ command: Int) {
        guard let ptr = CFBundleGetFunctionPointerForName(MediaRemote.bundle, "MRMediaRemoteSendCommand" as CFString) else { return }
        let MRMediaRemoteSendCommand = unsafeBitCast(ptr, to: funcType.self)
        MRMediaRemoteSendCommand(command, nil)
    }
    
    // MARK: MediaRemote Commands
    
    enum MediaRemoteCommands: Int {
        case togglePlayPause = 2
        case forward = 4
        case rewind = 5
    }
    
    func controlMedia(command: MediaRemoteCommands) {
        sendCommand(command.rawValue)
    }
}
