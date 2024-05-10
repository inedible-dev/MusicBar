//
//  SongArtworkView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

@available(macOS 12.0, *)
struct SongArtworkView: View {
    
    var artwork: Data?
    
    var mediaPlaying: Bool?
    
    var isWidget: Bool?
    
    var body: some View {
        VStack {
            if let albumArtwork = artwork, let albumArtworkImage = NSImage(data: albumArtwork), albumArtworkImage.size.width != 0 {
                ZStack {
                    if albumArtworkImage.size.width / albumArtworkImage.size.height > 1.01 || albumArtworkImage.size.width / albumArtworkImage.size.height > 0.09 {
                        Rectangle()
                            .background(albumArtworkImage.averageColor)
                    }
                    Image(nsImage: albumArtworkImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }.aspectRatio(1, contentMode: .fill)
            } else {
                VStack {
                    Image("double.note")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .opacity(0.5)
                        .padding(isWidget == true ? 30 : 55)
                }.background(Color.init(white: 0.5))
            }
        }.cornerRadius(8)
            .scaleEffect(mediaPlaying != false ? 1 : 0.8)
            .frame(maxWidth: 270, maxHeight: 270)
            .shadow(color: .black.opacity(0.3), radius: 8)
    }
}
