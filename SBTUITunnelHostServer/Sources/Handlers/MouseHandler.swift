// Copyright (C) 2023 Subito.it
//
// Licensed under the Apache License, Version 2.0 (the "License");

// MouseHandler.swift
//
// Copyright (C) 2023 Subito.it
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
import os.log

class MouseHandler: BaseHandler {
    private static let mouseExecutionQueue = DispatchQueue.main

    private let requestMethod = "POST"
    private static let handlerTimeout = 15.0

    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> Void)) {
        let requestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self

        webServer.addHandler(forMethod: requestMethod, pathRegex: "/mouse/(.*)", request: requestClass, processBlock: { request in
            // swiftlint:disable:next force_cast
            let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query

            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerErrorResponse(statusCode: 701)
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

            // swiftlint:disable:next implicitly_unwrapped_optional
            var ret: GCDWebServerDataResponse!
            MouseHandler.mouseExecutionQueue.sync {
                guard let simulatorInfo = try? self.findSimulator(descriptor: simulatorDescriptor) else {
                    os_log("%{public}@", "Couldn't find simulator info \(simulatorDescriptor)")
                    return
                }
                try? self.bringApplicationToFrontIfNeeded(pid: simulatorInfo.0)

                let app_width = NSRectFromString(appFrameString).size.width
                let dimensionRatio = simulatorInfo.1.size.width / app_width

                let deviceOrigin = simulatorInfo.1.origin

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

                        try? self.bringApplicationToFrontIfNeeded(pid: simulatorInfo.0)
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
                        try? self.bringApplicationToFrontIfNeeded(pid: simulatorInfo.0)
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

    private enum Error: Swift.Error {
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
                  descriptor.recogniseSimulator(from: windowName)
            else {
                continue
            }

            guard let bounds = infoList["kCGWindowBounds"] as? [String: Any],
                  let x = bounds["X"] as? Int,
                  let y = bounds["Y"] as? Int,
                  let w = bounds["Width"] as? Int,
                  let h = bounds["Height"] as? Int
            else {
                os_log("%{public}@", "Simulator window bounds missing")
                throw Error.RuntimeError("Simulator window bounds missing")
            }

            guard let pid = infoList["kCGWindowOwnerPID"] as? pid_t else {
                os_log("%{public}@", "pid not found for \(windowName)")
                throw Error.RuntimeError("Failed getting Simulator pid")
            }
            
            // To determine window bar height I found no better way than doing a wild guess base on the possible aspect ratio
            // 1.33 iPad
            // 1.5 iPad mini
            // 1.4375 iPad air 4
            let aspectRatios = [2.1666, 1.3333, 1.4375, 1.5]
            
            let expectedHeigths = aspectRatios.map { $0 * Double(w) }
            let menuBarHeigths = expectedHeigths.map { h - Int($0.rounded()) }
            
            let defaultWindowBarHeight = 55
            let windowBarHeight = menuBarHeigths.first(where: { $0 >= 55 && $0 <= 57 }) ?? defaultWindowBarHeight
        
            return (pid, CGRect(x: x, y: y + windowBarHeight, width: w, height: h - windowBarHeight))
        }

        if let screenshot = CGWindowListCreateImage(.infinite, .optionOnScreenOnly, 0, .bestResolution) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd-HHmmss"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")

            let filename: NSString = "~/Library/Logs/DiagnosticReports/SBTUITestTunnelServer_\(dateFormatter.string(from: Date())).png" as NSString
            let absolutePath = filename.expandingTildeInPath
            let fileUrl = URL(fileURLWithPath: absolutePath)
            writeToFile(image: screenshot, url: fileUrl)
        }

        throw Error.RuntimeError("Simulator not not found while looking for \(descriptor)")
    }

    private func bringApplicationToFrontIfNeeded(pid: pid_t) throws {
        // It is important to understand that we cannot bring a specific window to front but only an applicaiton pid
        // This needs improvement

        guard let runningApp = NSRunningApplication(processIdentifier: pid) else {
            os_log("%{public}@", "Running application with pid \(pid) not found!")

            throw Error.RuntimeError("Running application with pid \(pid) not found!")
        }

        guard !runningApp.isActive else {
            return
        }

        if !runningApp.activate(options: NSApplication.ActivationOptions.activateIgnoringOtherApps) {
            os_log("%{public}@", "Failed bringing Simulator to front")

            throw Error.RuntimeError("Failed bringing Simulator to front")
        }
        Thread.sleep(forTimeInterval: 0.25)
    }

    private func writeToFile(image: CGImage, url: URL) {
        let bitmapRep = NSBitmapImageRep(cgImage: image)
        if let data = bitmapRep.representation(using: NSBitmapImageRep.FileType.png, properties: [:]) {
            try? data.write(to: url)
        }
    }
}
