//
//  StatusBarController.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Foundation
import AppKit


struct MediaRemoteInfo: Equatable {
    var songTitle: String?
    var songArtist: String?
    var albumArtwork: NSImage?
    var isPlaying: Bool?
    var elapsedTime: Double?
    var duration: TimeInterval?
    var isLive: Bool?
    var isMusicApp: Bool?
}

class MediaRemote: ObservableObject {
    
    @Published var mediaInfo = MediaRemoteInfo()
    
    var firstLaunchInitiated = false
    
    private static let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
    
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    typealias MRNowPlayingClientGetBundleIdentifierFunction = @convention(c) (AnyObject?) -> String
    typealias funcType = @convention(c) (Int, NSDictionary?) -> Void
    
    // MARK: - Get Now Playing from Local MediaRemote Framework
    
    func getNowPlaying() -> MRMediaRemoteGetNowPlayingInfoFunction? {
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(MediaRemote.bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return nil }
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get a Swift function for MRNowPlayingClientGetBundleIdentifier
        guard CFBundleGetFunctionPointerForName(MediaRemote.bundle, "MRNowPlayingClientGetBundleIdentifier" as CFString) != nil else { return nil }
        
        return MRMediaRemoteGetNowPlayingInfo
    }
    
    // MARK: - Analyze Now Playing Algorithm
    
    @objc func fetchNowPlaying() {
        if let getNowPlaying = getNowPlaying() {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                
                let pastTitle = self.mediaInfo.songTitle
                let pastArtist = self.mediaInfo.songArtist
                
                if information["kMRMediaRemoteNowPlayingInfoTitle"] as? String == nil &&
                    information["kMRMediaRemoteNowPlayingInfoArtist"] as? String == nil {
                    self.mediaInfo = MediaRemoteInfo()
                } else {
                    if let timestamp = information["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date {
                        
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
                                self.mediaInfo.elapsedTime = interval
                            } else {
                                if isMusicApp != true && self.mediaInfo.isPlaying == true  {
                                    self.mediaInfo.isLive = true
                                }
                            }
                        } else {
                            self.mediaInfo.isLive = false
                            self.mediaInfo.elapsedTime = Date().timeIntervalSince(timestamp)
                        }
                        
                        let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double
                        
                        if playbackRate == 0 || playbackRate == nil {
                            self.mediaInfo.isPlaying = false
                            if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
                                self.mediaInfo.elapsedTime = elapsedTime
                            }
                        } else {
                            self.mediaInfo.isPlaying = true
                        }
                        
                        if let infoTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                            if infoTitle != self.mediaInfo.songTitle {
                                self.mediaInfo.elapsedTime = 0
                            }
                            self.mediaInfo.songTitle = infoTitle
                        }
                        
                        if let infoArtist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                            self.mediaInfo.songArtist = infoArtist
                        }
                        
                        if let infoImageData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                            self.mediaInfo.albumArtwork = NSImage(data: infoImageData)
                        } else {
                            if let title = self.mediaInfo.songTitle,
                               let artist = self.mediaInfo.songArtist,
                               pastTitle != title || pastArtist != artist {
                                self.mediaInfo.albumArtwork = nil
                            }
                        }
                    } else {
                        self.mediaInfo.elapsedTime = nil
                    }
                }
            })
        }
    }
    
    // MARK: - Send MediaRemote Commands
    
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
        fetchNowPlaying()
    }
}
