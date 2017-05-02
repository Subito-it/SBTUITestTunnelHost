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


import Foundation
import Cocoa
import GCDWebServer

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, GCDWebServerDelegate {

    @IBOutlet weak var window: NSWindow!
    
    let bonjourServiceName = "com.sbtuitesttunnel.mac.host"
    let serverPort: UInt = 8667

    let statusBar = NSStatusBar.system()
    var statusBarItem : NSStatusItem = NSStatusItem()
    
    var statusBarImageTimer = Timer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        self.statusBarItem = self.statusBar.statusItem(withLength: NSVariableStatusItemLength)
        self.restoreDefaultStatusBarImage()
        
        startup()
    }
    
    func startup() {
        guard let webServer = GCDWebServer() else {
            exit(-1)
        }
        
        let handlers: [BaseHandler] = [ExecHandler(), CatHandler(), MouseHandler()]
        handlers.forEach {
            $0.addHandler(webServer) { [unowned self] menubarTitle in
                self.updateMenuBarWithTitle(menubarTitle)
            }
        }
        
        webServer.delegate = self
        webServer.start(withPort: self.serverPort, bonjourName: self.bonjourServiceName)
    }
    
    private func updateMenuBarWithTitle(_ title: String) {
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit SBTUITestTunnelServer", action: #selector(NSApp.terminate), keyEquivalent: ""))
        
        DispatchQueue.main.async {
            self.statusBarItem.menu = menu
            
            self.statusBarItem.image = NSImage(named: "menuicon-red")
            self.statusBarImageTimer.invalidate()
            self.statusBarImageTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.restoreDefaultStatusBarImage), userInfo: nil, repeats: false)
        }
    }
    
    func webServerDidStart(_ server: GCDWebServer!) {
        updateMenuBarWithTitle("Running: " + server.serverURL.description)
    }
    
    func restoreDefaultStatusBarImage() {
        self.statusBarItem.image = NSImage(named: "menuicon")
    }    
}
