//
//  ActionButton.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 7/6/23.
//

import SwiftUI

struct ActionButtonViewModifier: ViewModifier {
    
    @Binding var toggled: Bool
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(toggled ? Color.init(white: 0.9).opacity(0.1) : Color.clear)
            .clipShape(Circle())
            .scaleEffect(toggled ? 0.9 : 1)
            .onHover(perform: {
                over in
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggled = over
                }
            })
    }
}

