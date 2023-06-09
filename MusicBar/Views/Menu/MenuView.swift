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
}

@available(macOS 11.0, *)
struct MenuView: View {
    @ObservedObject var info: MediaRemote
    
    @State var buttonsHovered = ButtonHovered()
    
    var body: some View {
        VStack {
            VStack {
                SongArtworkView(mediaInfo: $info.mediaInfo)
                VStack {
                    VStack(spacing: 2) {
                        SongTitleView(songTitle: info.mediaInfo.songTitle)
                        SongArtistView(songArtist: info.mediaInfo.songArtist)
                    }
                    VStack {
                        if info.mediaInfo.isLive == true {
                            LiveBar()
                        } else if let elapsedTime = info.mediaInfo.elapsedTime, let duration = info.mediaInfo.duration {
                            VStack {
                                DurationBar(value: Double(elapsedTime) / duration)
                                    .frame(height: 8)
                                SongDurationView(elapsedTime: elapsedTime, duration: duration)
                            }.padding(.vertical, 8)
                        } else {
                            DurationBar(value: 0)
                                .frame(height: 8)
                                .padding(.vertical, 12)
                        }
                    }
                }.padding(.horizontal, 2)
                HStack {
                    if info.mediaInfo.isLive != true {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .rewind)
                    }
                    if info.mediaInfo.isPlaying == true {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .pause)
                    } else {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .play)
                    }
                    if info.mediaInfo.isLive != true {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .forward)
                    }
                }
            }
            Spacer()
        }.padding(12)
            .artworkBackground(nsImage: info.mediaInfo.albumArtwork)
            .frame(width: 300, height: 500)
    }
}
