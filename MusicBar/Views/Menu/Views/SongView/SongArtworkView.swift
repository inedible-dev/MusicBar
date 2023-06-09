//
//  SongArtworkView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

@available(macOS 11.0, *)
struct SongArtworkView: View {
    
    @Binding var mediaInfo: MediaRemoteInfo
    @State var mediaPlaying = false
    
    var body: some View {
        VStack {
            if let albumArtwork = mediaInfo.albumArtwork, albumArtwork.size.width != 0 {
                ZStack {
                    if albumArtwork.size.width != albumArtwork.size.height {
                        Rectangle()
                            .background(Color.init(white: 0.15))
                            .opacity(0.3)
                    }
                    Image(nsImage: albumArtwork)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .onChange(of: mediaInfo) { mediaInfo in
                            if let isPlaying = mediaInfo.isPlaying {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    mediaPlaying = isPlaying
                                }
                            }
                        }
                }.aspectRatio(1, contentMode: .fill)
                    .cornerRadius(8)
                    .padding(mediaPlaying ? 0 : 40)
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
    }
}
