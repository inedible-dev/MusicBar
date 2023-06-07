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
        content.buttonStyle(PlainButtonStyle())
            .font(.system(size: 36))
            .padding()
            .background(toggled ? Color.init(white: 0.1).opacity(0.3) : Color.clear)
            .clipShape(Circle())
            .onHover(perform: {
                over in
                withAnimation(.easeInOut(duration: 0.2)) {
                    toggled = over
                }
            })
    }
}

