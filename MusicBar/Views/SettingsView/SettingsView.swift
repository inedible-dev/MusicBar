//
//  SettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 2/10/23.
//

import SwiftUI

@available(macOS 12.0, *)
struct SettingsView: View {
    @State var selectedMenu: SelectedSettingsMenu = .general
    @State var isFocused = false
    
    var body: some View {
        VStack {
            switch selectedMenu {
            case .general:
                Text("General Tab")
            case .statusBar:
                Text("Status Bar Tab")
            }
        }.toolbar {
            ToolbarItemGroup(placement: .principal) {
                ToolbarButton(title: SelectedSettingsMenu.general, systemName: "gearshape", isFocused: isFocused, selectedMenu: $selectedMenu)
                ToolbarButton(title: SelectedSettingsMenu.statusBar, systemName: "rectangle.2.swap", isFocused: isFocused, selectedMenu: $selectedMenu)
            }
        }.frame(minWidth: 480, minHeight: 300)
            .fixedSize() 
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeKeyNotification), perform: { _ in
                isFocused = true
            })
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification), perform: { _ in
                isFocused = false
            })
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didBecomeMainNotification), perform: { _ in
                isFocused = true
            })
            .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResignMainNotification), perform: { _ in
                isFocused = false
            })
    }
}
