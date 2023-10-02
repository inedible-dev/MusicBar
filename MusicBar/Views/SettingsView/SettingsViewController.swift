//
//  SettingsView.swift
//  MusicBar
//
//  Created by Wongkraiwich Chuenchomphu on 2/10/23.
//


import Cocoa
import SwiftUI

class SettingsViewController: NSObject, NSWindowDelegate {
    
    let hostingController = NSHostingController(rootView: SettingsView())
    
    var window: NSWindow?
    
    var isAlreadySetup = false
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleExitSettings), name: Notification.Name("HandleExitSettings"), object: nil)
    }
    
    func setup() {
        
        window = NSWindow(contentViewController: hostingController)
        
        let closeButton = window?.standardWindowButton(.closeButton)
        
        closeButton?.action = #selector(NSWindow.handleCustomClose(_:))
        
        
        window?.setContentSize(NSSize(width: 380, height: 400))
        
        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        
        NSApp.activate(ignoringOtherApps: true)
        
        window?.styleMask.formUnion(.fullSizeContentView)
        
        NSApp.windows[0].makeKeyAndOrderFront(self)
        
        window?.delegate = self
        
        isAlreadySetup = true
    }
    
    @objc func handleExitSettings() {
        isAlreadySetup = false
    }
}

extension NSWindow {
    @objc func handleCustomClose(_ sender: Any?) {
        NSApp.setActivationPolicy(.accessory)
        NotificationCenter.default.post(name: Notification.Name("HandleExitSettings"), object: nil)
        
        self.close()
    }
}

