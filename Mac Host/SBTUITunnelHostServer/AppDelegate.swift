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
    var serverBindToLocalhost = false
    var serverBindToLocalhostMenuItem = NSMenuItem(title: "Bind connections to localhost", action: #selector(toggleBindToLocalHostClicked), keyEquivalent: "")
    var server: GCDWebServer?

    let statusBar = NSStatusBar.system()
    var statusBarItem : NSStatusItem = NSStatusItem()
    
    var statusBarImageTimer = Timer()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let args = ProcessInfo().arguments

        statusBarItem = statusBar.statusItem(withLength: NSVariableStatusItemLength)
        restoreDefaultStatusBarImage()
    
        serverBindToLocalhost = args.contains("--skipLocalhostBinding")
        toggleBindToLocalHost()
    }
    
    func startup() {
        server?.stop()
        server = GCDWebServer()
        
        guard let server = server else {
            exit(-1)
        }
        
        let handlers: [BaseHandler] = [ExecHandler(), CatHandler(), MouseHandler()]
        handlers.forEach {
            $0.addHandler(server) { [unowned self] menubarTitle in
                self.updateMenuBarWithTitle(menubarTitle)
            }
        }
        
        server.delegate = self
        try? server.start(options: [GCDWebServerOption_BindToLocalhost: serverBindToLocalhost,
                                    GCDWebServerOption_BonjourName: bonjourServiceName,
                                    GCDWebServerOption_Port: serverPort])
    }
    
    func toggleBindToLocalHostClicked() {
        if serverBindToLocalhost {
            let alert = NSAlert.init()
            alert.messageText = "Warning"
            alert.informativeText = "Disabling this option will enable access outside localhost on port \(serverPort). For your securitu make sure this port is not reachable from unwanted clients"
            alert.addButton(withTitle: "OK")
            alert.addButton(withTitle: "Cancel")
            
            let result = alert.runModal()
            if result == NSAlertFirstButtonReturn {
                toggleBindToLocalHost()
            }
        } else {
            toggleBindToLocalHost()
        }
    }
    
    func toggleBindToLocalHost() {
        serverBindToLocalhost = !serverBindToLocalhost
        serverBindToLocalhostMenuItem.state = serverBindToLocalhost ? 1 : 0
        
        startup()
    }
    
    private func updateMenuBarWithTitle(_ title: String) {
        self.statusBarItem.menu?.removeItem(serverBindToLocalhostMenuItem)
        
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] ?? ""
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: title, action: nil, keyEquivalent: ""))
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(serverBindToLocalhostMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit SBTUITestTunnelServer (\(appVersion))", action: #selector(NSApp.terminate), keyEquivalent: ""))
        
        DispatchQueue.main.async {
            self.statusBarItem.menu = menu
            
            self.statusBarItem.image = NSImage(named: "menuicon-red")
            self.statusBarImageTimer.invalidate()
            self.statusBarImageTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.restoreDefaultStatusBarImage), userInfo: nil, repeats: false)
        }
    }
    
    func webServerDidStart(_ server: GCDWebServer!) {
        guard let serverURL = server.serverURL else {
            return
        }
        
        updateMenuBarWithTitle("Running: " + serverURL.description)
    }
    
    func restoreDefaultStatusBarImage() {
        self.statusBarItem.image = NSImage(named: "menuicon")
    }    
}
