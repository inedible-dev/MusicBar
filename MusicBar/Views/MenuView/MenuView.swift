//
//  MenuView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 23/4/23.
//

import SwiftUI

let colorStops: [Gradient.Stop] = [
    .init(color: .white, location: 0),
    .init(color: .white, location: 0.5),
    .init(color: .clear, location: 1)
]

struct ButtonHovered {
    var play = false
    var prev = false
    var next = false
    var settings = false
}

@available(macOS 12.0, *)
struct MenuView: View {
    @ObservedObject var info: MediaRemote
    
    func getElapsedTime() -> Double? {
        if let timestamp = info.mediaInfo.timestamp {
            switch info.mediaInfo.elapsedTimeState {
            case .useElapsedTime:
                return info.mediaInfo.elapsedTime
            case .useIntervalAndElapsedTime:
                if let elapsedTime = info.mediaInfo.elapsedTime {
                    return Date().timeIntervalSince(timestamp) + elapsedTime
                } else {
                    return Date().timeIntervalSince(timestamp)
                }
            case nil:
                return nil
            }
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack {
            VStack {
                TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                    SongArtworkView(mediaInfo: $info.mediaInfo)
                    VStack {
                        HStack {
                            VStack(spacing: 2) {
                                SongTitleView(songTitle: info.mediaInfo.songTitle)
                                SongArtistView(songArtist: info.mediaInfo.songArtist)
                            }
                        }.padding(.vertical, 4)
                        VStack {
                            if info.mediaInfo.isLive == true {
                                LiveBar()
                            } else if let elapsedTime = getElapsedTime(), let duration = info.mediaInfo.duration {
                                VStack {
                                    DurationBar(value: Double(elapsedTime) / duration)
                                        .frame(height: 8)
                                    SongDurationView(elapsedTime: elapsedTime, elapsedTimeState: info.mediaInfo.elapsedTimeState, duration: duration)
                                }
                                
                            } else {
                                DurationBar(value: 0)
                                    .frame(height: 8)
                            }
                        }.padding(.vertical, 10)
                    }.padding(.horizontal, 2)
                }
                HStack {
                    if info.mediaInfo.isLive != true {
                        MediaControlButton(command: .rewind)
                    }
                    MediaControlButton(command: .playPause, isPlaying: info.mediaInfo.isPlaying)
                    if info.mediaInfo.isLive != true {
                        MediaControlButton(command: .forward)
                    }
                }
            }.padding(.top, 5)
                .padding(.horizontal, 5)
            Spacer()
            HStack(spacing: 2) {
                Spacer()
                TransparentButton(systemName: "gear") {
                    NotificationCenter.default.post(name: Notification.Name("OpenSettings"), object: nil)
                }
                TransparentButton(systemName: "power") {
                    NSApplication.shared.terminate(nil)
                }
            }.padding(.horizontal, 6)
        }.padding(10)
            .artworkBackground(nsImage: NSImage(data: info.mediaInfo.albumArtwork ?? Data()))
            .frame(maxWidth: 300, maxHeight: 550)
    }
}
