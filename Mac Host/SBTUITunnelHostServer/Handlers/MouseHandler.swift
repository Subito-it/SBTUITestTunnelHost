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

class CatHandler: BaseHandler {
    
    private let requestMethod = "GET"
    
    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ())) {
        let execRequestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addDefaultHandler(forMethod: requestMethod, request: execRequestClass, processBlock: { request in
            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
            
            switch requestPath {
            case "/mouse":
                let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query
                
                if !self.validToken(params) {
                    menubarUpdated("Check token")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 5])
                }
                
                let repeatCount = params?["repeat_count"] as? Int ?? 0
                let repeatDelay = params?["repeat_delay"] as? Int ?? 0
                let startX = params?["start_x"] as? Float ?? 0.0
                let startY = params?["start_y"] as? Float ?? 0.0
                let stopX = params?["stop_x"] as? Float ?? 0.0
                let stopY = params?["stop_y"] as? Float ?? 0.0
                
                var bounds: CGRect = .zero
                do {
                    var pid: pid_t
                    (pid, bounds) = try self.findSimulator()
                    try self.bringWindowToFront(pid: pid)
                } catch {
                    print(error)
                    exit(EX_USAGE)
                }
                
                switch params?["action"] as? String ?? "" {
                case "click":
                    return GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 1])
                    
                case "drag":
                    return GCDWebServerDataResponse(jsonObject: ["result": "ok", "status": 1])
                    
                default:
                    menubarUpdated("Unkown action")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 2])
                }
                
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
            
            return (pid, CGRect(x: x, y: y, width: w, height: h))
        }
        
        throw Error.RuntimeError("Simulator not running")
    }
    
    private func bringWindowToFront(pid: pid_t) throws {
        if NSRunningApplication(processIdentifier: pid)?.activate(options: .activateIgnoringOtherApps) == false {
            throw Error.RuntimeError("Failed bringing Simulator to front")
        }
    }
}
