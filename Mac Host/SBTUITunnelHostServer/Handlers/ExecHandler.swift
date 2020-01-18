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
    
    private func parseCommand(_ params: [AnyHashable: Any]) -> String? {
        guard let encodedCommand = params["command"] as? String,
            let decdedData = Data(base64Encoded: encodedCommand),
            let decodedCommand = String(data: decdedData, encoding: .utf8)
            else { return nil }
        
        return decodedCommand
    }
    
    private func parseUUID(_ params: [AnyHashable: Any]) -> UUID? {
        guard let idString = params["command"] as? String else {
            return nil
        }
        
        return UUID(uuidString: idString)
    }
    
    private func responseForCommandStatus(
        _ status: ProcessEnvironment.Status?
    ) -> GCDWebServerResponse {
        switch status {
        case .none:
            return GCDWebServerResponse(statusCode: 404)
        case .running(pid: let pid):
            return GCDWebServerDataResponse(jsonObject: ["result": [
                "pid": pid
                ]
            ])
        case let .finished(standardOutput: stdOut,
                           standardError: stdErr, 
                           terminationStatus: status,
                           terminationReason: reason):
            var jsonObject: [String : Any] = [
                "terminationStatus": status,
                "terminationReason": reason.rawValue
            ]
            
            if let stdOut = stdOut {
                jsonObject["stdOut"] = stdOut
            }
            
            if let stdErr = stdErr {
                jsonObject["stdErr"] = stdErr
            }
            
            return GCDWebServerDataResponse(
                jsonObject: ["result": jsonObject]
            )
        }
    }
    
    private func validate(
        command: String,
        errorHandler: (String) -> Void
    ) -> GCDWebServerErrorResponse? {
        var cmd = command
        
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
                errorHandler("WTF!")
                return GCDWebServerErrorResponse(statusCode: 703)
            }
            else {
                return nil
            }
        } catch {
            errorHandler("Regex failed?")
            return GCDWebServerErrorResponse(statusCode: 704)
        }
    }
    
    func addHandler(_ webServer: GCDWebServer,
                    menubarUpdated: @escaping ((String) -> ())) {
        let requestClass = (requestMethod == "POST") ?
            GCDWebServerURLEncodedFormRequest.self :
            GCDWebServerRequest.self
        
        func addHandlerForParameter<T>(
            _ path: String,
            parser paramsParser: @escaping ([AnyHashable: Any]) -> T?,
            responseForItem: @escaping ((T) -> GCDWebServerResponse)
        ) {
            webServer.addHandler(
                forMethod: self.requestMethod, 
                path: path,
                request: requestClass,
                processBlock: { request in
                    let params = (self.requestMethod == "POST") ? (request as! GCDWebServerURLEncodedFormRequest).arguments : request?.query
                    
                    guard self.validToken(params) else {
                        menubarUpdated("Check token")
                        return GCDWebServerErrorResponse(statusCode: 702)
                    }
                    
                    guard let p = params, let item = paramsParser(p) else {
                        menubarUpdated("Missing parameter!")
                        return GCDWebServerErrorResponse(statusCode: 705)
                    }
                    
                    return responseForItem(item)
            })
        }
        
        addHandlerForParameter("/exec", parser: parseCommand) { command in
            if let error = self.validate(command: command,
                                         errorHandler: menubarUpdated) {
                return error
            }
            
            let cmdOutput = executeShellCommand(
                command,
                basePath: self.executablesBasePath
            )
            
            menubarUpdated("Executed: \(command)")
            
            return GCDWebServerDataResponse(jsonObject: [
                "result": cmdOutput,
                "status": 1
            ])
        }
        
        addHandlerForParameter("/launch", parser: parseCommand) { command in
            if let error = self.validate(command: command,
                                         errorHandler: menubarUpdated) {
                return error
            }
            
            let id = launchShellCommand(command,
                                        basePath: self.executablesBasePath)
            
            menubarUpdated("Launch: \(command)")
            
            return GCDWebServerDataResponse(jsonObject: [
                "result": id.uuidString,
                "status": 1
            ])
        }
        
        addHandlerForParameter("/status", parser: parseUUID) { id in
            return self.responseForCommandStatus(getShellCommandStatus(for: id))
        }
                
        addHandlerForParameter("/interrupt", parser: parseUUID) { id in
            return self.responseForCommandStatus(interruptCommand(with: id))
        }
                
        addHandlerForParameter("/terminate", parser: parseUUID) { id in
            return self.responseForCommandStatus(terminateCommand(with: id))
        }
                
    }

}
