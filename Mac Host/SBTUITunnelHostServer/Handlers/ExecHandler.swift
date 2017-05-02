// ExecHandler.swift
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

class ExecHandler: BaseHandler {
    
    private let requestMethod = "POST"
    private var executablesBasePath = "~/Desktop"

    func addHandler(_ webServer: GCDWebServer, menubarUpdated: @escaping ((String) -> ())) {
        let execRequestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addDefaultHandler(forMethod: requestMethod, request: execRequestClass, processBlock: { request in
            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 1])
            }
            
            switch requestPath {
            case "/exec":
                let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query
                
                if !self.validToken(params) {
                    menubarUpdated("Check token")
                    return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 5])
                }
                
                if let cmdB64 = params?["command"] as? String,
                    let cmdData = Data(base64Encoded: cmdB64, options: NSData.Base64DecodingOptions(rawValue: 0)),
                    var cmd = String(data: cmdData, encoding: String.Encoding.utf8) {
                    
                    do {
                        let regex = try NSRegularExpression(pattern: ".*?(?:(;|&))", options: .caseInsensitive)
                        
                        regex.enumerateMatches(in: cmd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, cmd.characters.count)) {
                            (substringRange: NSTextCheckingResult?, _, _) in
                            if let substringRange = substringRange {
                                let cmd2 = cmd as NSString
                                
                                cmd = cmd2.substring(with: substringRange.range)
                            }
                        }
                        
                        if cmd.hasPrefix("rm ") {
                            menubarUpdated("WTF!")
                            return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 4])
                        }
                    } catch {
                        menubarUpdated("Regex failed?")
                        return GCDWebServerDataResponse(jsonObject: ["status": 0, "error": 3])
                    }
                    
                    let cmdOutput = executeShellCommand(cmd, basePath: self.executablesBasePath)
                    menubarUpdated("Executed: \(cmd)")
                    return GCDWebServerDataResponse(jsonObject: ["result": cmdOutput, "status": 1])
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
