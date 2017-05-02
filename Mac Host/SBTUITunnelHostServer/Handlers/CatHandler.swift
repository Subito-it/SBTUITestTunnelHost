// CatHandler.swift
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
    
    private let requestMethod = "GET"
    
    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ())) {
        let catfileRequestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addDefaultHandler(forMethod: requestMethod, request: catfileRequestClass, processBlock: { request in
            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
            switch requestPath {
            case "/catfile":
                let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query
                
                if !self.validToken(params) {
                    menubarUpdated("Check token")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 5])
                }
                
                if let filePath = params?["path"] as? String,
                    let fileContentType = params?["content-type"] as? String {
                    
                    if !FileManager.default.fileExists(atPath: filePath) {
                        menubarUpdated("File does not exists")
                        return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 4])
                    } else {
                        let fileURL = URL(fileURLWithPath: filePath)
                        menubarUpdated("Catting file \(fileURL.lastPathComponent)")
                        do {
                            let fileData = try Data(contentsOf: fileURL)
                            return GCDWebServerDataResponse(data: fileData, contentType: fileContentType)
                        } catch {
                            menubarUpdated("Failed reading file?")
                            return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 3])
                        }
                    }
                } else {
                    menubarUpdated("Missing parameter!")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 2])
                }
            default:
                menubarUpdated("Unkown command")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
        })
    }
}
