//
//  StatusBarController.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Foundation
import AppKit
import MediaPlayer


struct MediaInfo: Equatable {
    var songTitle: String?
    var songArtist: String?
    var albumArtwork: NSImage?
    var isPlaying: Bool?
    var elapsedTime: Double?
    var duration: TimeInterval?
    var isLive: Bool?
}

class GetNowPlaying: ObservableObject {
    
    @Published var mediaInfo = MediaInfo()
    
    var firstLaunchInitiated = false
    
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    typealias MRNowPlayingClientGetBundleIdentifierFunction = @convention(c) (AnyObject?) -> String
    
    // MARK: - Get Now Playing from Local MediaRemote Framework
    
    func getNowPlaying() -> MRMediaRemoteGetNowPlayingInfoFunction? {
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return nil }
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get a Swift function for MRNowPlayingClientGetBundleIdentifier
        guard CFBundleGetFunctionPointerForName(bundle, "MRNowPlayingClientGetBundleIdentifier" as CFString) != nil else { return nil }
        
        return MRMediaRemoteGetNowPlayingInfo
    }
    
    // MARK: - Analyze Now Playing Algorithm
    
    @objc func fetchNowPlaying() {
        if let getNowPlaying = getNowPlaying() {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double,
                   let timestamp = information["kMRMediaRemoteNowPlayingInfoTimestamp"] as? Date,
                   let duration = information["kMRMediaRemoteNowPlayingInfoDuration"] as? Double {
                    
                    self.mediaInfo.duration = duration
                    
                    let interval = Date().timeIntervalSince(timestamp) + elapsedTime
                    
                    if interval.truncatingRemainder(dividingBy: 3600) < duration.truncatingRemainder(dividingBy: 3600) {
                        self.mediaInfo.isLive = false
                        self.mediaInfo.elapsedTime = interval
                    } else {
                        self.mediaInfo.isLive = true
                    }
                    
                    if let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
                        if playbackRate == 0 {
                            self.mediaInfo.isPlaying = false
                            if let elapsedTime = information["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double {
                                self.mediaInfo.elapsedTime = elapsedTime
                            }
                        } else {
                            self.mediaInfo.isPlaying = true
                        }
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
                        self.mediaInfo.albumArtwork = nil
                    }
                } else {
                    self.mediaInfo.elapsedTime = nil
                }
            })
        }
    }
}
