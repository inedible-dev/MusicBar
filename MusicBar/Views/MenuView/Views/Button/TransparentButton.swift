//
//  TransparentButton.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 2/10/23.
//

import SwiftUI

@available(macOS 11.0, *)
struct TransparentButton: View {
    
    var systemName: String
    var action: () -> Void
    
    @State var isHovered = false
    
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .padding(6)
                .opacity(isHovered ? 0.9 : 0.5)
                .onHover(perform: {
                    over in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = over
                    }
                })
        }.buttonStyle(PlainButtonStyle())
    }
}
