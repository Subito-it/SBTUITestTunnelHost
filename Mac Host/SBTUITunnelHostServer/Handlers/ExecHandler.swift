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
        let requestClass = (requestMethod == "POST") ? GCDWebServerURLEncodedFormRequest.self : GCDWebServerRequest.self
        
        webServer.addHandler(forMethod: requestMethod, path: "/exec", request: requestClass, processBlock: { request in
            guard let requestPath = request?.path else {
                menubarUpdated("Unknown path")
                return GCDWebServerErrorResponse(statusCode: 701)
            }
            
            switch requestPath {
            case "/exec":
                let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query
                
                guard self.validToken(params) else {
                    menubarUpdated("Check token")
                    return GCDWebServerErrorResponse(statusCode: 702)
                }
                
                if let cmdB64 = params?["command"] as? String,
                    let cmdData = Data(base64Encoded: cmdB64, options: NSData.Base64DecodingOptions(rawValue: 0)),
                    var cmd = String(data: cmdData, encoding: String.Encoding.utf8) {
                    
                    do {
                        let regex = try NSRegularExpression(pattern: ".*?(?:(;|&))", options: .caseInsensitive)
                        
                        regex.enumerateMatches(in: cmd, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, cmd.count)) {
                            (substringRange: NSTextCheckingResult?, _, _) in
                            if let substringRange = substringRange {
                                let cmd2 = cmd as NSString
                                
                                cmd = cmd2.substring(with: substringRange.range)
                            }
                        }
                        
                        if cmd.hasPrefix("rm ") {
                            menubarUpdated("WTF!")
                            return GCDWebServerErrorResponse(statusCode: 703)
                        }
                    } catch {
                        menubarUpdated("Regex failed?")
                        return GCDWebServerErrorResponse(statusCode: 704)
                    }
                    
                    let cmdOutput = executeShellCommand(cmd, basePath: self.executablesBasePath)
                    menubarUpdated("Executed: \(cmd)")
                    return GCDWebServerDataResponse(jsonObject: ["result": cmdOutput, "status": 1])
                } else {
                    menubarUpdated("Missing parameter!")
                    return GCDWebServerErrorResponse(statusCode: 705)
                }
            default:
                menubarUpdated("Unkown command")
                return GCDWebServerErrorResponse(statusCode: 706)
            }
        })
    }
}
