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
}

class GetNowPlaying: ObservableObject {
    
    @Published var mediaInfo: MediaInfo = MediaInfo(songTitle: "", songArtist: "", albumArtwork: NSImage(), isPlaying: false)
    var firstLaunchInitiated = false
    
    typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]) -> Void) -> Void
    typealias MRNowPlayingClientGetBundleIdentifierFunction = @convention(c) (AnyObject?) -> String
    
    func getNowPlaying() -> MRMediaRemoteGetNowPlayingInfoFunction? {
        let bundle = CFBundleCreate(kCFAllocatorDefault, NSURL(fileURLWithPath: "/System/Library/PrivateFrameworks/MediaRemote.framework"))
        
        guard let MRMediaRemoteGetNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) else { return nil }
        let MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(MRMediaRemoteGetNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
        
        // Get a Swift function for MRNowPlayingClientGetBundleIdentifier
        guard CFBundleGetFunctionPointerForName(bundle, "MRNowPlayingClientGetBundleIdentifier" as CFString) != nil else { return nil }
        
        return MRMediaRemoteGetNowPlayingInfo
    }
    
    @objc func fetchNowPlaying() {
        if let getNowPlaying = getNowPlaying() {
            getNowPlaying(DispatchQueue.main, {
                (information) in
                if let infoTitle = information["kMRMediaRemoteNowPlayingInfoTitle"] as? String {
                    self.mediaInfo.songTitle = infoTitle
                    print(infoTitle)
                }
                if let infoArtist = information["kMRMediaRemoteNowPlayingInfoArtist"] as? String {
                    self.mediaInfo.songArtist = infoArtist
                }
                if let infoImageData = information["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                    self.mediaInfo.albumArtwork = NSImage(data: infoImageData)
                }
                if let playbackRate = information["kMRMediaRemoteNowPlayingInfoPlaybackRate"] as? Double {
                    print(playbackRate)
                    if playbackRate == 0 {
                        self.mediaInfo.isPlaying = false
                    } else {
                        self.mediaInfo.isPlaying = true
                    }
                }
            })
        }
    }
    
}
