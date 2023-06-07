//
//  View+Extension.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 7/6/23.
//

import SwiftUI

extension View {
    func artworkBackground(nsImage: NSImage?) -> some View {
        modifier(ArtworkBackgroundViewModifier(artwork: nsImage))
    }
    
    func actionsButton(toggled: Binding<Bool>) -> some View {
        modifier(ActionButtonViewModifier(toggled: toggled))
    }
}
