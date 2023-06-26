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

@available(macOS 11.0, *)
struct MenuView: View {
    @ObservedObject var info: MediaRemote
    
    @State var buttonsHovered = ButtonHovered()
    
    var body: some View {
        VStack {
            VStack {
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
                        } else if let elapsedTime = info.mediaInfo.elapsedTime, let duration = info.mediaInfo.duration {
                            VStack {
                                DurationBar(value: Double(elapsedTime) / duration)
                                    .frame(height: 8)
                                SongDurationView(elapsedTime: elapsedTime, duration: duration)
                            }
                        } else {
                            DurationBar(value: 0)
                                .frame(height: 8)
                        }
                    }.padding(.vertical, 10)
                }.padding(.horizontal, 2)
                HStack {
                    if info.mediaInfo.isLive != true {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .rewind)
                    }
                    MediaControls(buttonsHovered: $buttonsHovered, command: .playPause, isPlaying: info.mediaInfo.isPlaying)
                    if info.mediaInfo.isLive != true {
                        MediaControls(buttonsHovered: $buttonsHovered, command: .forward)
                    }
                }
            }.padding(.top, 5)
                .padding(.horizontal, 5)
            Spacer()
            VStack {
                Button(action: {
                    NSApp.setActivationPolicy(.regular)
                }) {
                    HStack {
                        Text("Settings")
                        Spacer()
                        Text("⌘P")
                    }.padding(6)
                        .opacity(0.5)
                        .background(buttonsHovered.settings ? Color.init(white: 0.9).opacity(0.1) : Color.clear)
                        .cornerRadius(6)
                        .onHover(perform: {
                            over in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                buttonsHovered.settings = over
                            }
                        })
                }.buttonStyle(PlainButtonStyle())
            }
        }.padding(10)
            .artworkBackground(nsImage: info.mediaInfo.albumArtwork)
            .frame(width: 300, height: 550)
    }
}
