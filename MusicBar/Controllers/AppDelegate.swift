//
//  AppDelegate.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 11/16/22.
//

import Cocoa
import LaunchAtLogin
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    private var isLaunchedFirstTime = true
    
    private var statusBar: StatusBar!
    
    private var settingsViewController = SettingsViewController()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        
        isLaunchedFirstTime = UserDefaults.standard.bool(forKey: "isLaunchedFirstTime")
        
        if isLaunchedFirstTime {
            LaunchAtLogin.isEnabled = true
            UserDefaults.standard.set(false, forKey: "isLaunchedFirstTime")
        }
        //
        statusBar = StatusBar()
        
        NotificationCenter.default.addObserver(self, selector: #selector(showSettingsWindow), name: Notification.Name("OpenSettings"), object: nil)
    }
    @IBAction func showSettingsFromMenu(_ sender: Any) {
        showSettingsWindow()
    }
    
    @objc func showSettingsWindow() {
        if settingsViewController.isAlreadySetup {
            NSApp.windows[0].makeKeyAndOrderFront(self)
        } else {
            NSApp.setActivationPolicy(.regular)
            settingsViewController.setup()
        }
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
}
