// MouseHandler.swift
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
import GCDWebServer

class MouseHandler: BaseHandler {
    
    private let requestMethod = "POST"
    
    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ())) {
        let requestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addHandler(forMethod: requestMethod, pathRegex: "/mouse/(.*)", request: requestClass, processBlock: { request in
            let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query

            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
            
            guard self.validToken(params) else {
                menubarUpdated("Check token")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 5])
            }
            
            guard let commandB64 = params?["command"] as? String else {
                    menubarUpdated("What?")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 6])
            }
            
            guard let commandData = Data(base64Encoded: commandB64) else {
                    menubarUpdated("What?")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 6])
            }
            
            NSKeyedUnarchiver.setClass(SBTMouseClick.self, forClassName: "SBTUITunneledHostMouseClick")
            NSKeyedUnarchiver.setClass(SBTMouseDrag.self, forClassName: "SBTUITunneledHostMouseDrag")
            
            switch requestPath {
            case "/mouse/clicks":
                guard let mouseClicks = NSKeyedUnarchiver.unarchiveObject(with: commandData) as? [SBTMouseClick] else {
                    return GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 7])
                }
                
                var bounds: CGRect = .zero
                do {
                    var pid: pid_t
                    (pid, bounds) = try self.findSimulator()
                    try self.bringWindowToFront(pid: pid)
                } catch {
                    print(error)
                    exit(EX_USAGE)
                }
                
                let deviceOrigin = bounds.origin
                
                let mouse = Mouse()
                for mouseClick in mouseClicks {
                    let point = CGPoint(x: deviceOrigin.x + mouseClick.point.x, y: deviceOrigin.y + mouseClick.point.y)
                    mouse.click(at: point)

                    Thread.sleep(forTimeInterval: mouseClick.completionPause)
                }
                
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "result": "ok"])
            case "/mouse/drags":
                guard let mouseDrags = NSKeyedUnarchiver.unarchiveObject(with: commandData) as? [SBTMouseDrag] else {
                    return GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 8])
                }
                
                var bounds: CGRect = .zero
                do {
                    var pid: pid_t
                    (pid, bounds) = try self.findSimulator()
                    try self.bringWindowToFront(pid: pid)
                    Thread.sleep(forTimeInterval: 0.01)
                } catch {
                    print(error)
                    exit(EX_USAGE)
                }
                
                let deviceOrigin = bounds.origin
                
                let mouse = Mouse()
                for mouseDrag in mouseDrags {
                    let startPoint = CGPoint(x: deviceOrigin.x + mouseDrag.startPoint.x, y: deviceOrigin.y + mouseDrag.startPoint.y)
                    let stopPoint = CGPoint(x: deviceOrigin.x + mouseDrag.stopPoint.x, y: deviceOrigin.y + mouseDrag.stopPoint.y)
                    mouse.drag(from: startPoint, to: stopPoint, duration: mouseDrag.dragDuration)
                    
                    Thread.sleep(forTimeInterval: mouseDrag.completionPause)
                }
                
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "result": "ok"])

            default:
                menubarUpdated("Unkown command")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
        })
    }
    
    private enum Error : Swift.Error {
        case RuntimeError(String)
    }
    
    private func findSimulator() throws -> (pid_t, CGRect) {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        
        guard let infosList = windowListInfo as NSArray? as? [[String: AnyObject]] else {
            throw Error.RuntimeError("Failed to get window list info")
        }
        
        for infoList in infosList {
            guard let windowName = infoList["kCGWindowOwnerName"] as? String,
                windowName == "Simulator" else {
                    continue
            }
            
            guard let bounds = infoList["kCGWindowBounds"] as? [String: Any],
                let x = bounds["X"] as? Int,
                let y = bounds["Y"] as? Int,
                let w = bounds["Width"] as? Int,
                let h = bounds["Height"] as? Int else {
                    throw Error.RuntimeError("Simulator window bounds missing")
            }
            
            guard let pid = infoList["kCGWindowOwnerPID"] as? pid_t else {
                throw Error.RuntimeError("Failed getting Simulator pid")
            }
            
            let windowBarHeight = 24
            
            return (pid, CGRect(x: x, y: y + windowBarHeight, width: w, height: h - windowBarHeight))
        }
        
        throw Error.RuntimeError("Simulator not running")
    }
    
    private func bringWindowToFront(pid: pid_t) throws {
        if NSRunningApplication(processIdentifier: pid)?.activate(options: .activateIgnoringOtherApps) == false {
            throw Error.RuntimeError("Failed bringing Simulator to front")
        }
    }
}
