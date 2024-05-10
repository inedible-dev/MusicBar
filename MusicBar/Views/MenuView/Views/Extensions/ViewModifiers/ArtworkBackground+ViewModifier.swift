//
//  ArtworkBackground.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 7/6/23.
//

import SwiftUI

struct ArtworkBackgroundViewModifier: ViewModifier {
    
    @Environment(\.colorScheme) var colorScheme
    
    var artwork: NSImage?
    
    func body(content: Content) -> some View {
        if #available(macOS 12.0, *), let artwork = artwork {
            content
                .background {
                    ZStack {
                        Image(nsImage: artwork)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 40)
                            .opacity(0.4)
                            .background(
                                Color.init(white: colorScheme == .dark ? 0.2 : 0.9)
                                    .opacity(colorScheme == .dark ? 0.5 : 0.9)
                            )
                    }
                }
        } else {
            content.background(Color.init(white: 0.4).blur(radius: 60))
        }
    }
}
