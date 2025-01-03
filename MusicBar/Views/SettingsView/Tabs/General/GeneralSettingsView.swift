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
        List {
            LaunchAtLogin.Toggle {
                HStack {
                    Text("Launch at login")
                    Spacer()
                }
            }.toggleStyle(.switch)
            Toggle(isOn: $songTitleOnly) {
                HStack {
                    Text("Song Title Only")
                    Spacer()
                }
            }.toggleStyle(.switch)
                .onChange(of: songTitleOnly) { _ in
                StatusBar.setMedia()
            }
            HStack {
//                Text("Max Status Bar Characters")
                TextField(value: $maxStatusBarCharacters.max(70), format: .number, prompt: Text("")) {
                    Text("Max Status Bar Characters")
                }
//                Stepper("", value: $maxStatusBarCharacters, in: 0...70)
//                    .onChange(of: maxStatusBarCharacters) { _ in
//                        StatusBar.setMedia()
//                    }
            }
        }.padding()
    }
}
