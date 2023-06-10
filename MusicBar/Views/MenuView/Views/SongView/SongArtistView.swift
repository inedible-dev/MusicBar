//
//  SongArtistView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

struct SongArtistView: View {
    var songArtist: String?
    
    var body: some View {
        HStack {
            MarqueeText(
                text: (songArtist != nil && ((songArtist?.isNotEmpty()) != nil)) ? songArtist! : "",
                font: NSFont.systemFont(ofSize: 16, weight: .regular),
                leftFade: 16,
                rightFade: 16,
                startDelay: 1
            ).opacity(0.7)
            Spacer()
        }
    }
}
