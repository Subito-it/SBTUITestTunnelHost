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
    
    private static let mouseExecutionQueue = DispatchQueue.main
    
    private let requestMethod = "POST"
    private static let handlerTimeout = 15.0
    
    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ())) {
        let requestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addHandler(forMethod: requestMethod, pathRegex: "/mouse/(.*)", request: requestClass, processBlock: { request in
            let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query

            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerErrorResponse(statusCode: 701)
            }
            
            guard self.validToken(params) else {
                menubarUpdated("Check token")
                return GCDWebServerErrorResponse(statusCode: 702)
            }
            
            guard let appFrameString = params?["app_frame"] as? String else {
                menubarUpdated("What?")
                return GCDWebServerErrorResponse(statusCode: 703)
            }
            
            guard let simulatorDescriptor = SimulatorDescriptor(requestParameters: params) else {
                menubarUpdated("What #2?")
                return GCDWebServerErrorResponse(statusCode: 704)
            }
            
            guard let commandB64 = params?["command"] as? String else {
                menubarUpdated("What?")
                return GCDWebServerErrorResponse(statusCode: 705)
            }
            
            guard let commandData = Data(base64Encoded: commandB64) else {
                menubarUpdated("What?")
                return GCDWebServerErrorResponse(statusCode: 706)
            }
            
            var ret: GCDWebServerDataResponse!
            MouseHandler.mouseExecutionQueue.sync {
                var simulator_bounds: CGRect = .zero
                var pid: pid_t

                (pid, simulator_bounds) = try! self.findSimulator(descriptor: simulatorDescriptor)
                try! self.bringWindowToFrontIfNeeded(pid: pid)
                
                let app_width = NSRectFromString(appFrameString).size.width
                let dimensionRatio = simulator_bounds.size.width / app_width
                
                let deviceOrigin = simulator_bounds.origin
                
                NSKeyedUnarchiver.setClass(SBTMouseClick.self, forClassName: "SBTUITunneledHostMouseClick")
                NSKeyedUnarchiver.setClass(SBTMouseDrag.self, forClassName: "SBTUITunneledHostMouseDrag")
                
                let eventStart = CFAbsoluteTimeGetCurrent()
                
                switch requestPath {
                case "/mouse/clicks":
                    guard let mouseClicks = NSKeyedUnarchiver.unarchiveObject(with: commandData) as? [SBTMouseClick] else {
                        ret = GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 9])
                        return
                    }
                    
                    let mouse = Mouse()
                    for mouseClick in mouseClicks {
                        let point = CGPoint(x: deviceOrigin.x + mouseClick.point.x * dimensionRatio, y: deviceOrigin.y + mouseClick.point.y * dimensionRatio)
                        
                        try! self.bringWindowToFrontIfNeeded(pid: pid)
                        mouse.click(at: point)
                        
                        Thread.sleep(forTimeInterval: mouseClick.completionPause)
                        
                        if CFAbsoluteTimeGetCurrent() - eventStart > MouseHandler.handlerTimeout {
                            menubarUpdated("Timeout reached, try reducing number of clicks")
                            ret = GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 11])
                            return
                        }
                    }
                    menubarUpdated("Mouse clicking...")
                    ret = GCDWebServerDataResponse(jsonObject: ["status": 0, "result": "ok"])
                    return
                case "/mouse/drags":
                    guard let mouseDrags = NSKeyedUnarchiver.unarchiveObject(with: commandData) as? [SBTMouseDrag] else {
                        ret = GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 10])
                        return
                    }
                    
                    let mouse = Mouse()
                    for mouseDrag in mouseDrags {
                        let startPoint = CGPoint(x: deviceOrigin.x + mouseDrag.startPoint.x * dimensionRatio,
                                                 y: deviceOrigin.y + mouseDrag.startPoint.y * dimensionRatio)
                        let stopPoint = CGPoint(x: deviceOrigin.x + mouseDrag.stopPoint.x * dimensionRatio,
                                                y: deviceOrigin.y + mouseDrag.stopPoint.y * dimensionRatio)
                        try! self.bringWindowToFrontIfNeeded(pid: pid)
                        mouse.drag(from: startPoint, to: stopPoint, duration: mouseDrag.dragDuration)
                        
                        Thread.sleep(forTimeInterval: mouseDrag.completionPause)
                        
                        if CFAbsoluteTimeGetCurrent() - eventStart > MouseHandler.handlerTimeout {
                            menubarUpdated("Timeout reached, try reducing number of drags")
                            ret = GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 12])
                            return
                        }
                    }
                    menubarUpdated("Mouse dragging...")
                    ret = GCDWebServerDataResponse(jsonObject: ["status": 0, "result": "ok"])
                    return
                    
                default:
                    menubarUpdated("Unkown command")
                    ret = GCDWebServerErrorResponse(statusCode: 707)
                    return
                }
            }
            
            return ret
        })
    }
    
    private enum Error : Swift.Error {
        case RuntimeError(String)
    }
    
    private func findSimulator(descriptor: SimulatorDescriptor) throws -> (pid_t, CGRect) {
        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, CGWindowListOption.optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, CGWindowID(0))
        
        guard let infosList = windowListInfo as NSArray? as? [[String: AnyObject]] else {
            throw Error.RuntimeError("Failed to get window list info")
        }
        
        for infoList in infosList {
            guard let windowName = infoList["kCGWindowName"] as? String,
                descriptor.recogniseSimulator(from: windowName) else {
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
        
        throw Error.RuntimeError("Simulator not not found while looking for \(descriptor)")
    }
    
    private func bringWindowToFrontIfNeeded(pid: pid_t) throws {
        guard let runningApp = NSRunningApplication(processIdentifier: pid) else {
            throw Error.RuntimeError("Running application with pid \(pid) not found!")
        }
        
        guard !runningApp.isActive else {
            return
        }
        
        if !runningApp.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps) {
            throw Error.RuntimeError("Failed bringing Simulator to front")
        }
        Thread.sleep(forTimeInterval: 0.25)
    }
}
