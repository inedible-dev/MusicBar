//
//  ToolbarIconItem.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 3/10/23.
//

import SwiftUI

@available(macOS 12.0, *)
struct ToolbarButton: View {
    var title: SelectedSettingsMenu
    var systemName: String
    var isFocused: Bool
    
    @Binding var selectedMenu: SelectedSettingsMenu
    
    @State private var isHovered = false
    
    var body: some View {
        Button(action: {
            if selectedMenu != title {
                selectedMenu = title
                NotificationCenter.default.post(name: Notification.Name("ChangeSettingsTitle"),
                                                object: nil,
                                                userInfo:["title": title.rawValue])
            }
        }) {
            VStack(spacing: 0) {
                Image(systemName: systemName)
                    .font(.system(size: 20))
                Text(title.rawValue)
                    .font(.system(size: 11))
            }.foregroundColor(selectedMenu == title || isHovered ? isFocused == true ? .accentColor : .init(white: 0.65) : isFocused == true ? .gray : .init(white: 0.4))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(selectedMenu == title || isHovered ? Color.init(white: 0.45, opacity: 0.3) : nil)
                .roundedCorners(radius: 4, corners: .allCorners)
        }.buttonStyle(.plain)
            .onHover { over in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = over
                }
            }
    }
}
