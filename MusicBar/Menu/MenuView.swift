//
//  MenuView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 23/4/23.
//

import SwiftUI

@available(macOS 11.0, *)
struct MenuView: View {
    @ObservedObject var info: GetNowPlaying
    
    @State var mediaPlaying = false
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if info.mediaInfo.albumArtwork != nil {
                    Image(nsImage: info.mediaInfo.albumArtwork!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(8)
                        .padding(.vertical, 10)
                        .padding(mediaPlaying ? 0 : 40)
                        .onChange(of: info.mediaInfo) { mediaInfo in
                            if let isPlaying = mediaInfo.isPlaying {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    mediaPlaying = isPlaying
                                }
                            }
                        }
                }
                HStack {
                    VStack(spacing: 2) {
                        if info.mediaInfo.songTitle != nil {
                            MarqueeText(
                                text: info.mediaInfo.songTitle!,
                                font: NSFont.systemFont(ofSize: 18, weight: .medium),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 1
                            )
                        }
                        if info.mediaInfo.songArtist != nil {
                            MarqueeText(
                                text: info.mediaInfo.songArtist!,
                                font: NSFont.systemFont(ofSize: 16, weight: .regular),
                                leftFade: 16,
                                rightFade: 16,
                                startDelay: 1
                            ).opacity(0.5)
                        }
                    }
                    Spacer()
                }.padding(.horizontal, 2)
                Spacer()
            }
            Spacer()
        }.padding(8)
            .artworkBackground(nsImage: info.mediaInfo.albumArtwork)
    }
}

struct ArtworkBackgroundExtension: ViewModifier {
    
    var artwork: NSImage?
    
    func body(content: Content) -> some View {
        if #available(macOS 12.0, *) {
            content.background {
                ZStack {
                    if artwork != nil {
                        Image(nsImage: artwork!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 60)
                            .opacity(0.7)
                    }
                }.edgesIgnoringSafeArea(.all)
            }
        }
    }
}

extension View {
    func artworkBackground(nsImage: NSImage?) -> some View {
        modifier(ArtworkBackgroundExtension(artwork: nsImage))
    }
}
