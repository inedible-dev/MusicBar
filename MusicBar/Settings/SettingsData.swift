//
//  SettingsData.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 6/6/23.
//

import LaunchAtLogin

class SettingsData {
    @objc func toggleLaunchAtLogin() {
        LaunchAtLogin.isEnabled = !LaunchAtLogin.isEnabled
    }
}
