//
//  ArtworkBackground.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 7/6/23.
//

import SwiftUI

struct ArtworkBackgroundViewModifier: ViewModifier {
    
    var artwork: NSImage?
    
    func body(content: Content) -> some View {
        if #available(macOS 12.0, *), let artwork = artwork {
            content
                .background {
                    ZStack {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 60)
                            .opacity(0.5)
                            .background(Color.init(white: 0.2).opacity(0.5))
                    }
                }
        } else {
            content.background(Color.init(white: 0.4).blur(radius: 60))
        }
    }
}
