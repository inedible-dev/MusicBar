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

func timeString(time: Double) -> String {
    let hour =  Int(time) / 3600
    let minute = Int(time) / 60 % 60
    let second = Int(time) % 60
    
    if hour > 0 {
        return String(format: "%02i:%02i:%02i", hour, minute, second)
    } else {
        return String(format: "%02i:%02i", minute, second)
    }
}

struct ButtonHovered {
    var play = false
    var prev = false
    var next = false
}

@available(macOS 11.0, *)
struct MenuView: View {
    @ObservedObject var info: MediaRemote
    
    @State var mediaPlaying = false
    @State var buttonsHovered = ButtonHovered()
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                VStack {
                    if let albumArtwork = info.mediaInfo.albumArtwork, albumArtwork.size.width != 0 {
                        Image(nsImage: albumArtwork)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .cornerRadius(8)
                            .padding(mediaPlaying ? 0 : 40)
                            .onChange(of: info.mediaInfo) { mediaInfo in
                                if let isPlaying = mediaInfo.isPlaying {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        mediaPlaying = isPlaying
                                    }
                                }
                            }
                    } else {
                        VStack {
                            Image("double.note")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .opacity(0.5)
                                .padding(55)
                        }.background(Color.init(white: 0.5))
                            .cornerRadius(8)
                    }
                }.shadow(color: .black.opacity(0.3), radius: 8)
                    .padding(.vertical, 10)
                VStack {
                    HStack {
                        VStack(spacing: 2) {
                            if let songTitle = info.mediaInfo.songTitle {
                                if songTitle.isNotEmpty() {
                                    MarqueeText(
                                        text: songTitle,
                                        font: NSFont.systemFont(ofSize: 18, weight: .medium),
                                        leftFade: 16,
                                        rightFade: 16,
                                        startDelay: 1
                                    )
                                } else {
                                    Text("No Song Title Specified")
                                        .font(.system(size: 16, weight: .medium))
                                }
                            } else {
                                Text("Not Playing")
                                    .font(.system(size: 16, weight: .medium))
                            }
                            if let artist = info.mediaInfo.songArtist, artist.isNotEmpty() {
                                MarqueeText(
                                    text: info.mediaInfo.songArtist ?? "",
                                    font: NSFont.systemFont(ofSize: 16, weight: .regular),
                                    leftFade: 16,
                                    rightFade: 16,
                                    startDelay: 1
                                ).opacity(0.7)
                            }
                        }
                        Spacer()
                    }
                    VStack {
                        if info.mediaInfo.isLive == true {
                            HStack(spacing: 2) {
                                Rectangle()
                                    .fill(LinearGradient(gradient: Gradient(stops: colorStops), startPoint: .leading, endPoint: .trailing))
                                    .roundedCorners(radius: 4, corners: [.topLeft, .bottomLeft])
                                    .opacity(0.6)
                                Text("LIVE")
                                    .fontWeight(.light)
                                Rectangle()
                                    .fill(LinearGradient(gradient: Gradient(stops: colorStops), startPoint: .trailing, endPoint: .leading))
                                    .roundedCorners(radius: 4, corners: [.topRight, .bottomRight])
                                    .opacity(0.6)
                            }.frame(height: 8).padding(.vertical, 12)
                        } else if let elapsedTime = info.mediaInfo.elapsedTime, let duration = info.mediaInfo.duration {
                            VStack {
                                DurationBar(value: Double(elapsedTime) / duration)
                                    .frame(height: 8)
                                HStack {
                                    Text(timeString(time: elapsedTime))
                                    Spacer()
                                    Text(timeString(time: duration))
                                }.opacity(0.5)
                                    .font(.system(size: 11))
                            }.padding(.vertical, 8)
                        } else {
                            DurationBar(value: 0)
                                .frame(height: 8)
                                .padding(.vertical, 12)
                        }
                    }
                }.padding(.horizontal, 2)
                Spacer()
                HStack {
                    if let isPlaying = info.mediaInfo.isPlaying {
                        Button(action: {
                            MediaRemote().togglePlayPause()
                        }) {
                            if isPlaying {
                                Image(systemName: "pause.fill")
                            } else {
                                Image(systemName: "play.fill")
                            }
                        }.actionsButton(toggled: $buttonsHovered.play)
                    }
                }
                Spacer()
            }
            Spacer()
        }.padding(12)
            .artworkBackground(nsImage: info.mediaInfo.albumArtwork)
            .frame(width: 300, height: 500)
    }
}
