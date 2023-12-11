//
//  GeneralSettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 3/10/23.
//

import SwiftUI
import LaunchAtLogin

@available(macOS 12.0, *)
struct GeneralSettingsView: View {
    
    @AppStorage("songTitleOnly") var songTitleOnly = false
    @AppStorage("limitText") var limitText = false
    @AppStorage("maxStatusBarCharacters") var maxStatusBarCharacters = 40
    
    var body: some View {
        VStack {
            LaunchAtLogin.Toggle {
                Text("Launch at login")
            }
            Toggle(isOn: $songTitleOnly) {
                Text("Song Title Only")
            }.onChange(of: songTitleOnly) { _ in
                StatusBar.setMedia()
            }
            HStack {
                Text("Max Status Bar Characters")
                TextField("", value: $maxStatusBarCharacters.max(70), format: .number)
                    .frame(maxWidth: 40)
                Stepper("", value: $maxStatusBarCharacters, in: 0...70)
                    .onChange(of: maxStatusBarCharacters) { _ in
                        StatusBar.setMedia()
                    }
            }
        }.padding()
    }
}
