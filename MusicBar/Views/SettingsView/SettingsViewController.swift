//
//  SettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 2/10/23.
//


import Cocoa
import SwiftUI

enum SelectedSettingsMenu: String {
    case general = "General",
         statusBar = "Status Bar"
}

class SettingsViewController: NSObject, NSWindowDelegate {
    
    var window: NSWindow?
    
    var isAlreadySetup = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitSettings), name: Notification.Name("HandleExitSettings"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setTitle), name: Notification.Name("ChangeSettingsTitle"), object: nil)
    }
    
    func setup() {
        
        if #available(macOS 12.0, *) {
            
            let hostingController = NSHostingController(rootView: SettingsView())
            
            window = NSWindow(contentViewController: hostingController)
            
            let closeButton = window?.standardWindowButton(.closeButton)
            
            closeButton?.action = #selector(NSWindow.handleCustomClose(_:))
            
            window?.toolbarStyle = .preference
            
            window?.title = SelectedSettingsMenu.general.rawValue
            
            window?.setContentSize(NSSize(width: 380, height: 400))
            
            let controller = NSWindowController(window: window)
            controller.showWindow(nil)
            
            NSApp.activate(ignoringOtherApps: true)
            
            window?.styleMask.formUnion(.fullSizeContentView)
            
            window?.makeKeyAndOrderFront(self)
            
            NSApp.windows[0].makeKeyAndOrderFront(self)
            
            window?.delegate = self
            
            isAlreadySetup = true
        }
    }
    
    @objc func handleExitSettings() {
        isAlreadySetup = false
    }
    
    @objc func setTitle(_ notification: Notification) {
        if let title = notification.userInfo?["title"] as? String {
            window?.title = title
        }
    }
}

extension NSWindow {
    @objc func handleCustomClose(_ sender: Any?) {
        NSApp.setActivationPolicy(.accessory)
        NotificationCenter.default.post(name: Notification.Name("HandleExitSettings"), object: nil)
        
        self.close()
    }
}

