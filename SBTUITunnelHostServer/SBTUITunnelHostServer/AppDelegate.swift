// AppDelegate.swift
//
// Copyright (C) 2017 Subito.it S.r.l (www.subito.it)
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Cocoa
import Foundation
import GCDWebServer

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GCDWebServerDelegate {
    @IBOutlet private var window: NSWindow!
    
    let serverPort: UInt = 8_667
    var server: GCDWebServer?
    
    var mouseInteractionEnabled: Bool = false
    
    let statusBar = NSStatusBar.system
    var statusBarItem = NSStatusItem()
    
    var statusBarImageTimer = Timer()
    
    var commandHistory = [String]()
    
    let appVersion: String = {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    }()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        mouseInteractionEnabled = ProcessInfo().arguments.contains("--enable-mouse-interaction")
        if mouseInteractionEnabled {
            let mouse = Mouse()
            let point = CGPoint(x: 0, y: 0)
            mouse.move(to: point)
        }
        
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        restoreDefaultStatusBarImage()
        
        startup()
    }
    
    func startup() {
        server?.stop()
        server = GCDWebServer()
        
        guard let server = server else {
            exit(-1)
        }
        
        let handlers: [BaseHandler] = [ExecHandler(), CatHandler(), MouseHandler()]
        handlers.forEach {
            $0.addHandler(server) { [weak self] menubarTitle in
                self?.updateMenuBarWithTitle(menubarTitle)
                print("[SBTUITestTunnelHost-Mac] \(menubarTitle)")
            }
        }
        
        server.delegate = self
        try? server.start(options: [GCDWebServerOption_BindToLocalhost: true,
                                    GCDWebServerOption_Port: serverPort])
    }
    
    private func updateMenuBarWithTitle(_ title: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            let menu = NSMenu()
            
            strongSelf.commandHistory.insert(title, at: 0)
            strongSelf.commandHistory = Array(strongSelf.commandHistory.prefix(25))
            
            let historyMenu = NSMenu()
            for command in strongSelf.commandHistory {
                historyMenu.addItem(NSMenuItem(title: command, action: nil, keyEquivalent: ""))
            }
            
            let historyMenuItem = NSMenuItem(title: "Command history", action: nil, keyEquivalent: "")
            historyMenuItem.submenu = historyMenu
            menu.addItem(historyMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit SBTUITestTunnelServer (\(strongSelf.appVersion))", action: #selector(NSApp.terminate), keyEquivalent: ""))
            
            strongSelf.statusBarItem.menu = menu
            
            strongSelf.statusBarItem.image = NSImage(named: "menuicon-red")
            strongSelf.statusBarImageTimer.invalidate()
            strongSelf.statusBarImageTimer = Timer.scheduledTimer(timeInterval: 1.5, target: strongSelf, selector: #selector(strongSelf.restoreDefaultStatusBarImage), userInfo: nil, repeats: false)
        }
    }
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    func webServerDidStart(_ server: GCDWebServer!) {
        guard let serverURL = server.serverURL else {
            return
        }
        
        updateMenuBarWithTitle("Running: " + serverURL.description)
    }
    
    @objc func restoreDefaultStatusBarImage() {
        statusBarItem.image = NSImage(named: "menuicon")
    }
}
