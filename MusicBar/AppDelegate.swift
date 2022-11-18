//
//  AppDelegate.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Cocoa
import LaunchAtLogin

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBar!
    private var isLaunchedFirstTime = true
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        isLaunchedFirstTime = UserDefaults.standard.bool(forKey: "isLaunchedFirstTime")
        if isLaunchedFirstTime {
            LaunchAtLogin.isEnabled = true
            UserDefaults.standard.set(false, forKey: "isLaunchedFirstTime")
        }
        statusBar = StatusBar()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }


}

