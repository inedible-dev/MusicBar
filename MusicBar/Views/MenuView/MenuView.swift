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
    
    @State var buttonsHovered = ButtonHovered()
    
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
                                    TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                                        DurationBar(value: Double(elapsedTime) / duration)
                                            .frame(height: 8)
                                        SongDurationView(elapsedTime: elapsedTime, elapsedTimeState: info.mediaInfo.elapsedTimeState, duration: duration)
                                    }
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
            HStack(spacing: 2) {
                Spacer()
                Button(action: {
                    NSApp.setActivationPolicy(.regular)
                    if #available(macOS 13, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }) {
                    Image(systemName: "gear")
                        .font(.title2)
                        .padding(6)
                        .opacity(buttonsHovered.settings ? 0.8 :0.5)
                        .onHover(perform: {
                            over in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                buttonsHovered.settings = over
                            }
                        })
                }.buttonStyle(PlainButtonStyle())
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .font(.title2)
                        .padding(6)
                        .opacity(buttonsHovered.settings ? 0.8 :0.5)
                        .onHover(perform: {
                            over in
                            withAnimation(.easeInOut(duration: 0.2)) {
                                buttonsHovered.settings = over
                            }
                        })
                }.buttonStyle(PlainButtonStyle())
            }.padding(.horizontal, 6)
        }.padding(10)
            .artworkBackground(nsImage: info.mediaInfo.albumArtwork)
            .frame(width: 300, height: 550)
    }
}
