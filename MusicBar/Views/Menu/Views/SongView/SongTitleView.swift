//
//  SongTitleView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 8/6/23.
//

import SwiftUI

struct SongTitleView: View {
    var songTitle: String?
    
    var body: some View {
        HStack {
            if let songTitle = songTitle {
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
            Spacer()
        }
    }
}
