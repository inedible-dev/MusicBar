//
//  GeneralSettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 3/10/23.
//

import SwiftUI
import LaunchAtLogin

struct GeneralSettingsView: View {
    var body: some View {
        VStack {
            LaunchAtLogin.Toggle {
                Text("Launch at login")
            }
        }.padding()
    }
}

#Preview {
    GeneralSettingsView()
}
